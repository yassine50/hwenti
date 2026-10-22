import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CacheEntry {
  final Map<String, dynamic> data;
  final int timestampMs;

  const _CacheEntry({
    required this.data,
    required this.timestampMs,
  });

  bool isFresh(Duration ttl) {
    final ageMs = DateTime.now().millisecondsSinceEpoch - timestampMs;
    return ageMs <= ttl.inMilliseconds;
  }
}

/// High-performance two-tier (L1 RAM LRU + L2 Persistent Disk) cache service
/// for API responses, reference data (governorates/delegations), and user state.
class AppCacheService {
  static final AppCacheService instance = AppCacheService._();
  factory AppCacheService() => instance;
  AppCacheService._();

  static const int _maxMemoryEntries = 120;
  static const String _prefsKeyPrefix = 'hwenti_cache_v1_';

  final LinkedHashMap<String, _CacheEntry> _l1Memory =
      LinkedHashMap<String, _CacheEntry>();

  Directory? _diskCacheDir;
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Boost Flutter's built-in decoded image cache for smooth scrolling
    try {
      PaintingBinding.instance.imageCache.maximumSize = 300;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 150 << 20; // 150MB
    } catch (_) {}

    try {
      _prefs = await SharedPreferences.getInstance();
      // Hydrate L1 memory cache from SharedPreferences keys for 0ms startup reads
      for (final rawKey in _prefs!.getKeys()) {
        if (rawKey.startsWith(_prefsKeyPrefix)) {
          final logicalKey = rawKey.substring(_prefsKeyPrefix.length);
          final rawJson = _prefs!.getString(rawKey);
          if (rawJson != null && rawJson.isNotEmpty) {
            final entry = _decodeEnvelope(rawJson);
            if (entry != null) {
              _putL1(logicalKey, entry);
            }
          }
        }
      }
    } catch (_) {}

    try {
      final baseDir = await getTemporaryDirectory();
      final dir = Directory('${baseDir.path}/hwenti_api_cache_v1');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _diskCacheDir = dir;
    } catch (_) {}
  }

  void _putL1(String key, _CacheEntry entry) {
    _l1Memory.remove(key);
    _l1Memory[key] = entry;
    while (_l1Memory.length > _maxMemoryEntries) {
      _l1Memory.remove(_l1Memory.keys.first);
    }
  }

  String _hashKey(String key) {
    return sha256.convert(utf8.encode(key)).toString();
  }

  _CacheEntry? _decodeEnvelope(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final ts = decoded['ts'];
        final payload = decoded['data'];
        if (ts is int && payload is Map) {
          return _CacheEntry(
            data: Map<String, dynamic>.from(payload),
            timestampMs: ts,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Synchronous L1 memory read (0ms latency) for instant initial screen build.
  Map<String, dynamic>? getSync(String key, {Duration? maxAge}) {
    final entry = _l1Memory[key];
    if (entry == null) return null;
    if (maxAge != null && !entry.isFresh(maxAge)) {
      return null;
    }
    // Refresh LRU order
    _l1Memory.remove(key);
    _l1Memory[key] = entry;
    return entry.data;
  }

  /// Reads from L1 Memory first, then falls back to L2 Disk / SharedPreferences.
  Future<Map<String, dynamic>?> get(
    String key, {
    Duration? ttl,
    bool allowStale = false,
  }) async {
    await init();

    final l1 = _l1Memory[key];
    if (l1 != null) {
      if (ttl == null || allowStale || l1.isFresh(ttl)) {
        _l1Memory.remove(key);
        _l1Memory[key] = l1;
        return l1.data;
      }
    }

    // Check SharedPreferences fast cache
    try {
      final prefsRaw = _prefs?.getString('$_prefsKeyPrefix$key');
      if (prefsRaw != null && prefsRaw.isNotEmpty) {
        final entry = _decodeEnvelope(prefsRaw);
        if (entry != null) {
          _putL1(key, entry);
          if (ttl == null || allowStale || entry.isFresh(ttl)) {
            return entry.data;
          }
        }
      }
    } catch (_) {}

    // Check L2 Disk file cache
    try {
      if (_diskCacheDir != null) {
        final file = File('${_diskCacheDir!.path}/${_hashKey(key)}.json');
        if (await file.exists()) {
          final raw = await file.readAsString();
          final entry = _decodeEnvelope(raw);
          if (entry != null) {
            _putL1(key, entry);
            if (ttl == null || allowStale || entry.isFresh(ttl)) {
              return entry.data;
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Saves data into L1 Memory immediately and persists to L2 Disk & SharedPreferences.
  Future<void> set(
    String key,
    Map<String, dynamic> data, {
    bool persistToPrefs = true,
  }) async {
    await init();
    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = _CacheEntry(data: data, timestampMs: now);
    _putL1(key, entry);

    final encoded = jsonEncode({
      'ts': now,
      'data': data,
    });

    if (persistToPrefs && encoded.length < 180000) {
      try {
        await _prefs?.setString('$_prefsKeyPrefix$key', encoded);
      } catch (_) {}
    }

    try {
      if (_diskCacheDir != null) {
        final file = File('${_diskCacheDir!.path}/${_hashKey(key)}.json');
        await file.writeAsString(encoded, flush: false);
      }
    } catch (_) {}
  }

  /// Invalidates all cache entries matching any of the given prefixes.
  Future<void> invalidateByPrefixes(List<String> prefixes) async {
    final keysToRemove = _l1Memory.keys
        .where((k) => prefixes.any((prefix) => k.startsWith(prefix)))
        .toList();
    for (final k in keysToRemove) {
      _l1Memory.remove(k);
    }

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final prefKeys = prefs.getKeys().toList();
      for (final pk in prefKeys) {
        if (pk.startsWith(_prefsKeyPrefix)) {
          final logical = pk.substring(_prefsKeyPrefix.length);
          if (prefixes.any((prefix) => logical.startsWith(prefix))) {
            await prefs.remove(pk);
          }
        }
      }
    } catch (_) {}

    try {
      if (_diskCacheDir != null && await _diskCacheDir!.exists()) {
        for (final k in keysToRemove) {
          final f = File('${_diskCacheDir!.path}/${_hashKey(k)}.json');
          if (await f.exists()) {
            await f.delete();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> clearUserScopedCache() async {
    await invalidateByPrefixes(const [
      'favorites',
      'follows',
      'notifications',
      'products_mine',
      'merchant_me',
      'products',
    ]);
  }
}
