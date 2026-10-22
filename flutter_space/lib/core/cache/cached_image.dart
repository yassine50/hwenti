import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Singleton L1 (RAM) + L2 (Disk) image byte cache so product photos and
/// merchant logos load in <1ms without re-downloading across tabs or app restarts.
class HwentiImageCache {
  static final HwentiImageCache instance = HwentiImageCache._();
  factory HwentiImageCache() => instance;
  HwentiImageCache._();

  static const int _maxRamImages = 90;
  final LinkedHashMap<String, Uint8List> _ramCache =
      LinkedHashMap<String, Uint8List>();
  final Map<String, Future<Uint8List?>> _inFlight = {};
  final http.Client _httpClient = http.Client();

  Directory? _diskDir;
  bool _dirInitialized = false;

  Future<Directory?> _getDiskDir() async {
    if (_dirInitialized) return _diskDir;
    _dirInitialized = true;
    try {
      final tmp = await getTemporaryDirectory();
      final dir = Directory('${tmp.path}/hwenti_img_cache_v1');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _diskDir = dir;
    } catch (_) {}
    return _diskDir;
  }

  Uint8List? getSync(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    final bytes = _ramCache.remove(trimmed);
    if (bytes != null) {
      _ramCache[trimmed] = bytes;
    }
    return bytes;
  }

  void _putRam(String url, Uint8List bytes) {
    _ramCache.remove(url);
    _ramCache[url] = bytes;
    while (_ramCache.length > _maxRamImages) {
      _ramCache.remove(_ramCache.keys.first);
    }
  }

  String _fileNameForUrl(String url) {
    final digest = sha256.convert(utf8.encode(url)).toString();
    return '$digest.img';
  }

  Future<Uint8List?> getOrFetch(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return Future.value(null);

    final ramHit = getSync(trimmed);
    if (ramHit != null) return Future.value(ramHit);

    final existingFuture = _inFlight[trimmed];
    if (existingFuture != null) return existingFuture;

    final future = _loadFromDiskOrNetwork(trimmed);
    _inFlight[trimmed] = future;
    future.whenComplete(() => _inFlight.remove(trimmed));
    return future;
  }

  Future<Uint8List?> _loadFromDiskOrNetwork(String url) async {
    // 1. Check L2 Disk cache
    try {
      final dir = await _getDiskDir();
      if (dir != null) {
        final file = File('${dir.path}/${_fileNameForUrl(url)}');
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) {
            _putRam(url, bytes);
            return bytes;
          }
        }
      }
    } catch (_) {}

    // 2. Download over HTTP and persist to L2 Disk + L1 RAM
    try {
      final response = await _httpClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.bodyBytes.isNotEmpty) {
        final bytes = response.bodyBytes;
        _putRam(url, bytes);
        try {
          final dir = await _getDiskDir();
          if (dir != null) {
            final file = File('${dir.path}/${_fileNameForUrl(url)}');
            await file.writeAsBytes(bytes, flush: false);
          }
        } catch (_) {}
        return bytes;
      }
    } catch (_) {}
    return null;
  }

  /// Prefetches a batch of image URLs into L1 RAM + L2 Disk in the background.
  Future<void> precacheUrls(Iterable<String?> urls, {int maxCount = 12}) async {
    int count = 0;
    for (final raw in urls) {
      if (raw == null) continue;
      final u = raw.trim();
      if (u.isEmpty) continue;
      if (count >= maxCount) break;
      count++;
      // Fire and forget so it warms up without blocking UI
      getOrFetch(u);
    }
  }
}

/// Drop-in cached network image widget with instant synchronous RAM hit,
/// persistent disk fallback, and zero flicker when scrolling or switching tabs.
class HwentiCachedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? placeholderBuilder;
  final Widget Function(BuildContext context)? errorBuilder;

  const HwentiCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  State<HwentiCachedImage> createState() => _HwentiCachedImageState();
}

class _HwentiCachedImageState extends State<HwentiCachedImage> {
  Uint8List? _bytes;
  bool _failed = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant HwentiCachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    final url = widget.imageUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _bytes = null;
        _failed = true;
        _loading = false;
      });
      return;
    }

    // Synchronous L1 RAM check -> 0ms render on first frame!
    final syncHit = HwentiImageCache.instance.getSync(url);
    if (syncHit != null) {
      setState(() {
        _bytes = syncHit;
        _failed = false;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _failed = false;
    });

    HwentiImageCache.instance.getOrFetch(url).then((loaded) {
      if (!mounted || widget.imageUrl.trim() != url) return;
      setState(() {
        _bytes = loaded;
        _failed = loaded == null || loaded.isEmpty;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null && _bytes!.isNotEmpty) {
      return Image.memory(
        _bytes!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) =>
            widget.errorBuilder?.call(context) ?? const SizedBox.shrink(),
      );
    }

    if (_failed && !_loading) {
      return widget.errorBuilder?.call(context) ?? const SizedBox.shrink();
    }

    return widget.placeholderBuilder?.call(context) ??
        Container(
          width: widget.width,
          height: widget.height,
          color: const Color(0xFFF1F5F9),
        );
  }
}
