import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hwenti_flutter/core/cache/app_cache_service.dart';
import 'package:hwenti_flutter/core/cache/cached_image.dart';
import 'package:hwenti_flutter/core/models/models.dart';

class ApiException implements Exception {
  final int status;
  final String message;

  const ApiException(this.status, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient instance = ApiClient._();
  factory ApiClient() => instance;
  ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3333',
  );

  static const String _tokenStorageKey = 'auth_token';
  String? _token;
  final http.Client _httpClient = http.Client();

  String get _cleanBaseUrl => baseUrl.replaceAll(RegExp(r'/+$'), '');

  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) return _token;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_tokenStorageKey);
      if (saved != null && saved.isNotEmpty) {
        _token = saved;
      }
    } catch (_) {}
    return _token;
  }

  Future<void> setToken(String? token) async {
    _token = (token != null && token.isNotEmpty) ? token : null;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_tokenStorageKey, _token!);
      } else {
        await prefs.remove(_tokenStorageKey);
      }
    } catch (_) {}
  }

  Future<void> clearToken() async {
    await setToken(null);
    await AppCacheService.instance.clearUserScopedCache();
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_cleanBaseUrl$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) return uri;

    final filtered = <String, String>{};
    queryParameters.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        filtered[key] = value.toString();
      }
    });
    if (filtered.isEmpty) return uri;
    return uri.replace(queryParameters: filtered);
  }

  Future<Map<String, String>> _buildHeaders({bool jsonBody = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    final rawBody = utf8.decode(response.bodyBytes);

    if (status >= 200 && status < 300) {
      if (status == 204 || rawBody.trim().isEmpty) {
        return <String, dynamic>{};
      }
      try {
        return jsonDecode(rawBody);
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    String errorMsg = 'Request failed ($status)';
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map) {
        final msg = decoded['message'] ?? decoded['error'];
        if (msg is List && msg.isNotEmpty) {
          errorMsg = msg.first.toString();
        } else if (msg is String && msg.trim().isNotEmpty) {
          errorMsg = msg.trim();
        }
      }
    } catch (_) {
      if (rawBody.trim().isNotEmpty && !rawBody.trimLeft().startsWith('<')) {
        errorMsg = rawBody.trim();
      }
    }
    throw ApiException(status, errorMsg);
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _httpClient
          .get(
            _buildUri(path, query),
            headers: await _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      final data = _handleResponse(response);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return <String, dynamic>{'items': data};
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, e.toString());
    }
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _httpClient
          .post(
            _buildUri(path),
            headers: await _buildHeaders(jsonBody: body != null),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 12));
      final data = _handleResponse(response);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, e.toString());
    }
  }

  Future<Map<String, dynamic>> _patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _httpClient
          .patch(
            _buildUri(path),
            headers: await _buildHeaders(jsonBody: body != null),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 12));
      final data = _handleResponse(response);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, e.toString());
    }
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    try {
      final response = await _httpClient
          .delete(
            _buildUri(path),
            headers: await _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      final data = _handleResponse(response);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, e.toString());
    }
  }

  String _productsCacheKey({
    String? governorateId,
    String? delegationId,
    String? tradeType,
    String? merchantId,
    String? search,
    bool? available,
    int page = 1,
    int limit = 50,
  }) {
    return 'products_${governorateId ?? ''}_${delegationId ?? ''}_${tradeType ?? ''}_${merchantId ?? ''}_${search ?? ''}_${available ?? ''}_${page}_$limit';
  }

  void _precacheProductsImages(List<ProductModel> items) {
    final urls = <String?>[];
    for (final p in items) {
      urls.add(p.primaryImageUrl);
      urls.add(p.merchant.logoUrl);
    }
    HwentiImageCache.instance.precacheUrls(urls, maxCount: 16);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AppUser> login(String email, String password) async {
    final data = await _post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    final token = data['token']?.toString();
    await setToken(token);
    await AppCacheService.instance.clearUserScopedCache();
    final rawUser = data['user'];
    if (rawUser is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return getMe();
  }

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final data = await _post(
      '/api/signup',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
    );
    final token = data['token']?.toString();
    await setToken(token);
    await AppCacheService.instance.clearUserScopedCache();
    final rawUser = data['user'];
    if (rawUser is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return getMe();
  }

  Future<AppUser> googleAuth({
    required String email,
    required String name,
    String role = 'visitor',
  }) async {
    final data = await _post(
      '/api/auth/google',
      body: {
        'email': email,
        'name': name,
        'role': role,
      },
    );
    final token = data['token']?.toString();
    await setToken(token);
    await AppCacheService.instance.clearUserScopedCache();
    final rawUser = data['user'];
    if (rawUser is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return getMe();
  }

  Future<AppUser> getMe() async {
    final data = await _get('/api/auth/me');
    final rawUser = data['user'] ?? data;
    if (rawUser is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(rawUser));
    }
    throw const ApiException(401, 'Invalid user response');
  }

  // ── 3-Step Presigned Image Upload ─────────────────────────────────────────

  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
    bool isPublic = true,
  }) async {
    final presigned = await _post(
      '/api/upload/presigned',
      body: {
        'fileName': fileName,
        'contentType': contentType,
        'isPublic': isPublic,
      },
    );

    final uploadUrl = presigned['uploadUrl']?.toString() ?? '';
    final cloudStoragePath = presigned['cloud_storage_path']?.toString() ?? '';
    if (uploadUrl.isEmpty || cloudStoragePath.isEmpty) {
      throw const ApiException(500, 'Invalid presigned upload response');
    }

    final putRes = await _httpClient.put(
      Uri.parse(uploadUrl),
      body: bytes,
      headers: {'Content-Type': contentType},
    );
    if (putRes.statusCode < 200 || putRes.statusCode >= 300) {
      throw ApiException(putRes.statusCode, 'Failed to upload image bytes');
    }

    final complete = await _post(
      '/api/upload/complete',
      body: {
        'cloud_storage_path': cloudStoragePath,
        'fileName': fileName,
        'contentType': contentType,
        'fileSize': bytes.length,
      },
    );

    final fileId = (complete['id'] ?? complete['fileId'] ?? '').toString();
    if (fileId.isEmpty) {
      throw const ApiException(500, 'Upload completion did not return fileId');
    }
    return fileId;
  }

  // ── Merchants ─────────────────────────────────────────────────────────────

  Future<MerchantModel> setupMerchant({
    required String shopName,
    required String tradeType,
    required String governorateId,
    required String delegationId,
    required String phone,
    String? logoFileId,
  }) async {
    final body = <String, dynamic>{
      'shopName': shopName,
      'tradeType': tradeType,
      'governorateId': governorateId,
      'delegationId': delegationId,
      'phone': phone,
    };
    if (logoFileId != null && logoFileId.isNotEmpty) {
      body['logoFileId'] = logoFileId;
    }
    final data = await _post('/api/merchants/setup', body: body);
    await AppCacheService.instance
        .invalidateByPrefixes(const ['merchant_me', 'merchants']);
    await AppCacheService.instance.set('merchant_me', data);
    return MerchantModel.fromJson(data);
  }

  Future<MerchantModel> updateMerchantMe({
    String? shopName,
    String? tradeType,
    String? governorateId,
    String? delegationId,
    String? phone,
    String? logoFileId,
  }) async {
    final body = <String, dynamic>{};
    if (shopName != null) body['shopName'] = shopName;
    if (tradeType != null) body['tradeType'] = tradeType;
    if (governorateId != null) body['governorateId'] = governorateId;
    if (delegationId != null) body['delegationId'] = delegationId;
    if (phone != null) body['phone'] = phone;
    if (logoFileId != null) body['logoFileId'] = logoFileId;

    final data = await _patch('/api/merchants/me', body: body);
    await AppCacheService.instance
        .invalidateByPrefixes(const ['merchant_me', 'merchants', 'products']);
    await AppCacheService.instance.set('merchant_me', data);
    return MerchantModel.fromJson(data);
  }

  Future<MerchantModel> getMerchantMe({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        'merchant_me',
        ttl: const Duration(minutes: 5),
      );
      if (cached != null) {
        return MerchantModel.fromJson(cached);
      }
    }
    try {
      final data = await _get('/api/merchants/me');
      await AppCacheService.instance.set('merchant_me', data);
      return MerchantModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.status == 404) {
        final me = await getMe();
        final list = await getMerchants(limit: 100);
        final match = list.items.where((m) => m.userId == me.id).toList();
        if (match.isNotEmpty) {
          return getMerchant(match.first.id);
        }
      }
      final stale =
          await AppCacheService.instance.get('merchant_me', allowStale: true);
      if (stale != null) {
        return MerchantModel.fromJson(stale);
      }
      rethrow;
    }
  }

  Future<MerchantModel> getMerchant(
    String id, {
    bool forceRefresh = false,
  }) async {
    final key = 'merchant_$id';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 5),
      );
      if (cached != null) {
        return MerchantModel.fromJson(cached);
      }
    }
    try {
      final data = await _get('/api/merchants/$id');
      await AppCacheService.instance.set(key, data);
      final model = MerchantModel.fromJson(data);
      if (model.logoUrl != null) {
        HwentiImageCache.instance.precacheUrls([model.logoUrl]);
      }
      return model;
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return MerchantModel.fromJson(stale);
      }
      rethrow;
    }
  }

  Future<PaginatedList<MerchantModel>> getMerchants({
    String? governorateId,
    String? delegationId,
    String? tradeType,
    String? search,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final key =
        'merchants_${governorateId ?? ''}_${delegationId ?? ''}_${tradeType ?? ''}_${search ?? ''}_${page}_$limit';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 5),
      );
      if (cached != null) {
        return PaginatedList.fromJson(cached, MerchantModel.fromJson);
      }
    }
    try {
      final data = await _get(
        '/api/merchants',
        query: {
          'governorateId': governorateId,
          'delegationId': delegationId,
          'tradeType': tradeType,
          'search': search,
          'page': page,
          'limit': limit,
        },
      );
      await AppCacheService.instance.set(key, data);
      final result = PaginatedList.fromJson(data, MerchantModel.fromJson);
      HwentiImageCache.instance.precacheUrls(
        result.items.map((m) => m.logoUrl),
      );
      return result;
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return PaginatedList.fromJson(stale, MerchantModel.fromJson);
      }
      rethrow;
    }
  }

  // ── Products (With L1 Sync + L2 Disk Cache) ───────────────────────────────

  /// Synchronous 0ms cache lookup for instant HomeTab & Filter rendering.
  PaginatedList<ProductModel>? getCachedProductsSync({
    String? governorateId,
    String? delegationId,
    String? tradeType,
    String? merchantId,
    String? search,
    bool? available,
    int page = 1,
    int limit = 50,
  }) {
    final key = _productsCacheKey(
      governorateId: governorateId,
      delegationId: delegationId,
      tradeType: tradeType,
      merchantId: merchantId,
      search: search,
      available: available,
      page: page,
      limit: limit,
    );
    final raw = AppCacheService.instance.getSync(key);
    if (raw == null) return null;
    try {
      return PaginatedList.fromJson(raw, ProductModel.fromJson);
    } catch (_) {
      return null;
    }
  }

  Future<PaginatedList<ProductModel>> getProducts({
    String? governorateId,
    String? delegationId,
    String? tradeType,
    String? merchantId,
    String? search,
    bool? available,
    int page = 1,
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    final key = _productsCacheKey(
      governorateId: governorateId,
      delegationId: delegationId,
      tradeType: tradeType,
      merchantId: merchantId,
      search: search,
      available: available,
      page: page,
      limit: limit,
    );

    if (!forceRefresh) {
      final fresh = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 3),
      );
      if (fresh != null) {
        final parsed = PaginatedList.fromJson(fresh, ProductModel.fromJson);
        _precacheProductsImages(parsed.items);
        return parsed;
      }
    }

    try {
      final data = await _get(
        '/api/products',
        query: {
          'governorateId': governorateId,
          'delegationId': delegationId,
          'tradeType': tradeType,
          'merchantId': merchantId,
          'search': search,
          'available': available?.toString(),
          'page': page,
          'limit': limit,
        },
      );
      await AppCacheService.instance.set(key, data);
      final parsed = PaginatedList.fromJson(data, ProductModel.fromJson);
      _precacheProductsImages(parsed.items);
      return parsed;
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return PaginatedList.fromJson(stale, ProductModel.fromJson);
      }
      rethrow;
    }
  }

  Future<PaginatedList<ProductModel>> getMyProducts({
    int page = 1,
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    final key = 'products_mine_${page}_$limit';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 2),
      );
      if (cached != null) {
        return PaginatedList.fromJson(cached, ProductModel.fromJson);
      }
    }
    try {
      final data = await _get(
        '/api/products/mine',
        query: {'page': page, 'limit': limit},
      );
      await AppCacheService.instance.set(key, data);
      return PaginatedList.fromJson(data, ProductModel.fromJson);
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return PaginatedList.fromJson(stale, ProductModel.fromJson);
      }
      rethrow;
    }
  }

  ProductModel? getCachedProductSync(String id) {
    final direct = AppCacheService.instance.getSync('product_$id');
    if (direct != null) {
      try {
        return ProductModel.fromJson(direct);
      } catch (_) {}
    }
    return null;
  }

  Future<ProductModel> getProduct(
    String id, {
    bool forceRefresh = false,
  }) async {
    final key = 'product_$id';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 3),
      );
      if (cached != null) {
        return ProductModel.fromJson(cached);
      }
    }
    try {
      final data = await _get('/api/products/$id');
      await AppCacheService.instance.set(key, data);
      final product = ProductModel.fromJson(data);
      HwentiImageCache.instance.precacheUrls([
        product.primaryImageUrl,
        ...product.images.map((img) => img.url),
        product.merchant.logoUrl,
      ]);
      return product;
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return ProductModel.fromJson(stale);
      }
      rethrow;
    }
  }

  Future<ProductModel> createProduct({
    required String name,
    required double price,
    required String phone,
    String? description,
    required DateTime expiryDate,
    DateTime? publishDate,
    required List<String> imageFileIds,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'price': price,
      'phone': phone,
      'expiryDate': expiryDate.toUtc().toIso8601String(),
      'imageFileIds': imageFileIds,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (publishDate != null) {
      body['publishDate'] = publishDate.toUtc().toIso8601String();
    }
    final data = await _post('/api/products', body: body);
    await AppCacheService.instance
        .invalidateByPrefixes(const ['products', 'products_mine']);
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> updateProduct(
    String id, {
    String? name,
    double? price,
    String? phone,
    String? description,
    DateTime? expiryDate,
    DateTime? publishDate,
    List<String>? imageFileIds,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (price != null) body['price'] = price;
    if (phone != null) body['phone'] = phone;
    if (description != null) body['description'] = description;
    if (expiryDate != null) {
      body['expiryDate'] = expiryDate.toUtc().toIso8601String();
    }
    if (publishDate != null) {
      body['publishDate'] = publishDate.toUtc().toIso8601String();
    }
    if (imageFileIds != null) body['imageFileIds'] = imageFileIds;

    final data = await _patch('/api/products/$id', body: body);
    await AppCacheService.instance.invalidateByPrefixes([
      'products',
      'products_mine',
      'product_$id',
      'favorites',
    ]);
    await AppCacheService.instance.set('product_$id', data);
    return ProductModel.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    await _delete('/api/products/$id');
    await AppCacheService.instance.invalidateByPrefixes([
      'products',
      'products_mine',
      'product_$id',
      'favorites',
    ]);
  }

  Future<int> incrementProductView(String id) async {
    final data = await _post('/api/products/$id/view');
    final vc = data['viewCount'];
    if (vc is int) return vc;
    if (vc is num) return vc.toInt();
    return 0;
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  Future<void> addFavorite(String productId) async {
    await _post('/api/favorites/$productId');
    await AppCacheService.instance.invalidateByPrefixes([
      'favorites',
      'products',
      'product_$productId',
    ]);
  }

  Future<void> removeFavorite(String productId) async {
    await _delete('/api/favorites/$productId');
    await AppCacheService.instance.invalidateByPrefixes([
      'favorites',
      'products',
      'product_$productId',
    ]);
  }

  PaginatedList<ProductModel>? getCachedFavoritesSync({
    int page = 1,
    int limit = 50,
  }) {
    final raw = AppCacheService.instance.getSync('favorites_${page}_$limit');
    if (raw == null) return null;
    try {
      return PaginatedList.fromJson(raw, ProductModel.fromJson);
    } catch (_) {
      return null;
    }
  }

  Future<PaginatedList<ProductModel>> getFavorites({
    int page = 1,
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    final key = 'favorites_${page}_$limit';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 2),
      );
      if (cached != null) {
        return PaginatedList.fromJson(cached, ProductModel.fromJson);
      }
    }
    try {
      final data = await _get(
        '/api/favorites',
        query: {'page': page, 'limit': limit},
      );
      await AppCacheService.instance.set(key, data);
      final parsed = PaginatedList.fromJson(data, ProductModel.fromJson);
      _precacheProductsImages(parsed.items);
      return parsed;
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return PaginatedList.fromJson(stale, ProductModel.fromJson);
      }
      rethrow;
    }
  }

  // ── Follows ───────────────────────────────────────────────────────────────

  Future<void> followMerchant(String merchantId) async {
    await _post('/api/follows/$merchantId');
    await AppCacheService.instance.invalidateByPrefixes(const ['follows']);
  }

  Future<void> unfollowMerchant(String merchantId) async {
    await _delete('/api/follows/$merchantId');
    await AppCacheService.instance.invalidateByPrefixes(const ['follows']);
  }

  Future<PaginatedList<FollowItemModel>> getFollows({
    int page = 1,
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    final key = 'follows_${page}_$limit';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 2),
      );
      if (cached != null) {
        return PaginatedList.fromJson(cached, FollowItemModel.fromJson);
      }
    }
    try {
      final data = await _get(
        '/api/follows',
        query: {'page': page, 'limit': limit},
      );
      await AppCacheService.instance.set(key, data);
      return PaginatedList.fromJson(data, FollowItemModel.fromJson);
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return PaginatedList.fromJson(stale, FollowItemModel.fromJson);
      }
      rethrow;
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<PaginatedList<NotificationItemModel>> getNotifications({
    int page = 1,
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    final key = 'notifications_${page}_$limit';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 1),
      );
      if (cached != null) {
        return PaginatedList.fromJson(cached, NotificationItemModel.fromJson);
      }
    }
    try {
      final data = await _get(
        '/api/notifications',
        query: {'page': page, 'limit': limit},
      );
      await AppCacheService.instance.set(key, data);
      return PaginatedList.fromJson(data, NotificationItemModel.fromJson);
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return PaginatedList.fromJson(stale, NotificationItemModel.fromJson);
      }
      rethrow;
    }
  }

  Future<void> markNotificationRead(String id) async {
    await _patch('/api/notifications/$id/read');
    await AppCacheService.instance.invalidateByPrefixes(const ['notifications']);
  }

  // ── Ratings & Reports ─────────────────────────────────────────────────────

  Future<void> rateMerchant(String merchantId, int score) async {
    await _post(
      '/api/merchants/$merchantId/ratings',
      body: {'score': score},
    );
    await AppCacheService.instance.invalidateByPrefixes([
      'merchant_$merchantId',
      'merchants',
      'ratings_$merchantId',
      'products',
    ]);
  }

  Future<RatingListResponse> getMerchantRatings(
    String merchantId, {
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final key = 'ratings_${merchantId}_${page}_$limit';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 3),
      );
      if (cached != null) {
        return RatingListResponse.fromJson(cached);
      }
    }
    try {
      final data = await _get(
        '/api/merchants/$merchantId/ratings',
        query: {'page': page, 'limit': limit},
      );
      await AppCacheService.instance.set(key, data);
      return RatingListResponse.fromJson(data);
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return RatingListResponse.fromJson(stale);
      }
      rethrow;
    }
  }

  Future<void> reportMerchant({
    required String merchantId,
    required String reason,
    String? details,
  }) async {
    final body = <String, dynamic>{
      'merchantId': merchantId,
      'reason': reason,
    };
    if (details != null && details.trim().isNotEmpty) {
      body['details'] = details.trim();
    }
    await _post('/api/reports', body: body);
  }

  // ── Governorates, Delegations & Geolocation (7-Day Reference Cache) ───────

  List<GovernorateModel>? getCachedGovernoratesSync() {
    final raw = AppCacheService.instance.getSync('governorates_all');
    if (raw == null) return null;
    final rawItems = (raw['items'] as List?) ?? const [];
    return rawItems
        .whereType<Map>()
        .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<GovernorateModel>> getGovernorates() async {
    const key = 'governorates_all';
    final cached = await AppCacheService.instance.get(
      key,
      ttl: const Duration(days: 7),
    );
    if (cached != null) {
      final rawItems = (cached['items'] as List?) ?? const [];
      if (rawItems.isNotEmpty) {
        return rawItems
            .whereType<Map>()
            .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    try {
      final data = await _get('/api/governorates');
      await AppCacheService.instance.set(key, data);
      final rawItems = (data['items'] as List?) ?? const [];
      return rawItems
          .whereType<Map>()
          .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        final rawItems = (stale['items'] as List?) ?? const [];
        return rawItems
            .whereType<Map>()
            .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      rethrow;
    }
  }

  List<DelegationModel>? getCachedDelegationsSync(String governorateId) {
    final raw =
        AppCacheService.instance.getSync('delegations_$governorateId');
    if (raw == null) return null;
    final rawItems = (raw['items'] as List?) ?? const [];
    return rawItems
        .whereType<Map>()
        .map((e) => DelegationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<DelegationModel>> getDelegations(String governorateId) async {
    final key = 'delegations_$governorateId';
    final cached = await AppCacheService.instance.get(
      key,
      ttl: const Duration(days: 7),
    );
    if (cached != null) {
      final rawItems = (cached['items'] as List?) ?? const [];
      if (rawItems.isNotEmpty) {
        return rawItems
            .whereType<Map>()
            .map((e) => DelegationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    try {
      final data = await _get('/api/governorates/$governorateId/delegations');
      await AppCacheService.instance.set(key, data);
      final rawItems = (data['items'] as List?) ?? const [];
      return rawItems
          .whereType<Map>()
          .map((e) => DelegationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        final rawItems = (stale['items'] as List?) ?? const [];
        return rawItems
            .whereType<Map>()
            .map((e) => DelegationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      rethrow;
    }
  }

  Future<NearestLocationResult> findNearestLocation(
    double latitude,
    double longitude,
  ) async {
    final latRounded = latitude.toStringAsFixed(2);
    final lngRounded = longitude.toStringAsFixed(2);
    final key = 'nearest_${latRounded}_$lngRounded';
    final cached = await AppCacheService.instance.get(
      key,
      ttl: const Duration(hours: 6),
    );
    if (cached != null) {
      return NearestLocationResult.fromJson(cached);
    }

    final data = await _post(
      '/api/geolocation/nearest',
      body: {'latitude': latitude, 'longitude': longitude},
    );
    await AppCacheService.instance.set(key, data);
    return NearestLocationResult.fromJson(data);
  }

  // ── Visitor Stats ─────────────────────────────────────────────────────────

  Future<void> trackVisitor({
    String? governorateId,
    String? delegationId,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{};
    if (governorateId != null && governorateId.isNotEmpty) {
      body['governorateId'] = governorateId;
    }
    if (delegationId != null && delegationId.isNotEmpty) {
      body['delegationId'] = delegationId;
    }
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    await _post('/api/visitor-stats/track', body: body);
  }

  Future<VisitorStatsSummary> getVisitorStatsSummary({
    bool forceRefresh = false,
  }) async {
    const key = 'visitor_stats_summary';
    if (!forceRefresh) {
      final cached = await AppCacheService.instance.get(
        key,
        ttl: const Duration(minutes: 3),
      );
      if (cached != null) {
        return VisitorStatsSummary.fromJson(cached);
      }
    }
    try {
      final data = await _get('/api/visitor-stats/summary');
      await AppCacheService.instance.set(key, data);
      return VisitorStatsSummary.fromJson(data);
    } catch (_) {
      final stale = await AppCacheService.instance.get(key, allowStale: true);
      if (stale != null) {
        return VisitorStatsSummary.fromJson(stale);
      }
      rethrow;
    }
  }
}
