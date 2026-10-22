double _toDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _toBool(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value != 0;
  return fallback;
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool merchantSetupComplete;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.merchantSetupComplete,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? 'visitor').toString(),
      merchantSetupComplete: _toBool(json['merchantSetupComplete']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'merchantSetupComplete': merchantSetupComplete,
      };
}

class GovernorateModel {
  final String id;
  final String name;
  final String nameAr;
  final String nameFr;

  const GovernorateModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.nameFr,
  });

  String localizedName(String locale) =>
      locale == 'ar' ? (nameAr.isNotEmpty ? nameAr : name) : (nameFr.isNotEmpty ? nameFr : name);

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['nameAr'] ?? json['nameFr'] ?? '').toString();
    final nameAr = (json['nameAr'] ?? name).toString();
    final nameFr = (json['nameFr'] ?? name).toString();
    return GovernorateModel(
      id: (json['id'] ?? '').toString(),
      name: name,
      nameAr: nameAr,
      nameFr: nameFr,
    );
  }
}

class DelegationModel {
  final String id;
  final String governorateId;
  final String name;
  final String nameAr;
  final String nameFr;

  const DelegationModel({
    required this.id,
    required this.governorateId,
    required this.name,
    required this.nameAr,
    required this.nameFr,
  });

  String localizedName(String locale) =>
      locale == 'ar' ? (nameAr.isNotEmpty ? nameAr : name) : (nameFr.isNotEmpty ? nameFr : name);

  factory DelegationModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['nameAr'] ?? json['nameFr'] ?? '').toString();
    final nameAr = (json['nameAr'] ?? name).toString();
    final nameFr = (json['nameFr'] ?? name).toString();
    return DelegationModel(
      id: (json['id'] ?? '').toString(),
      governorateId: (json['governorateId'] ?? '').toString(),
      name: name,
      nameAr: nameAr,
      nameFr: nameFr,
    );
  }
}

class MerchantModel {
  final String id;
  final String userId;
  final String? shopName;
  final String? tradeType;
  final String? governorateId;
  final String? governorateName;
  final String? governorateNameAr;
  final String? governorateNameFr;
  final String? delegationId;
  final String? delegationName;
  final String? delegationNameAr;
  final String? delegationNameFr;
  final String? phone;
  final String? logoFileId;
  final String? logoUrl;
  final double averageRating;
  final int ratingCount;
  final bool setupComplete;
  final String? createdAt;

  const MerchantModel({
    required this.id,
    required this.userId,
    this.shopName,
    this.tradeType,
    this.governorateId,
    this.governorateName,
    this.governorateNameAr,
    this.governorateNameFr,
    this.delegationId,
    this.delegationName,
    this.delegationNameAr,
    this.delegationNameFr,
    this.phone,
    this.logoFileId,
    this.logoUrl,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.setupComplete = false,
    this.createdAt,
  });

  String localizedGov(String locale) {
    if (locale == 'ar') {
      return governorateNameAr ?? governorateName ?? governorateNameFr ?? '';
    }
    return governorateNameFr ?? governorateName ?? governorateNameAr ?? '';
  }

  String localizedDel(String locale) {
    if (locale == 'ar') {
      return delegationNameAr ?? delegationName ?? delegationNameFr ?? '';
    }
    return delegationNameFr ?? delegationName ?? delegationNameAr ?? '';
  }

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      shopName: json['shopName']?.toString(),
      tradeType: json['tradeType']?.toString(),
      governorateId: json['governorateId']?.toString(),
      governorateName: json['governorateName']?.toString(),
      governorateNameAr: json['governorateNameAr']?.toString() ?? json['governorateName']?.toString(),
      governorateNameFr: json['governorateNameFr']?.toString() ?? json['governorateName']?.toString(),
      delegationId: json['delegationId']?.toString(),
      delegationName: json['delegationName']?.toString(),
      delegationNameAr: json['delegationNameAr']?.toString() ?? json['delegationName']?.toString(),
      delegationNameFr: json['delegationNameFr']?.toString() ?? json['delegationName']?.toString(),
      phone: json['phone']?.toString(),
      logoFileId: json['logoFileId']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      averageRating: _toDouble(json['averageRating']),
      ratingCount: _toInt(json['ratingCount']),
      setupComplete: _toBool(json['setupComplete'], true),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class ProductImageModel {
  final String id;
  final String fileId;
  final String url;
  final bool isPrimary;
  final int sortOrder;

  const ProductImageModel({
    required this.id,
    required this.fileId,
    required this.url,
    required this.isPrimary,
    required this.sortOrder,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: (json['id'] ?? '').toString(),
      fileId: (json['fileId'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      isPrimary: _toBool(json['isPrimary']),
      sortOrder: _toInt(json['sortOrder']),
    );
  }
}

class ProductMerchantSummary {
  final String id;
  final String? shopName;
  final double averageRating;
  final String? logoFileId;
  final String? logoUrl;

  const ProductMerchantSummary({
    required this.id,
    this.shopName,
    this.averageRating = 0.0,
    this.logoFileId,
    this.logoUrl,
  });

  factory ProductMerchantSummary.fromJson(Map<String, dynamic> json) {
    return ProductMerchantSummary(
      id: (json['id'] ?? '').toString(),
      shopName: json['shopName']?.toString(),
      averageRating: _toDouble(json['averageRating']),
      logoFileId: json['logoFileId']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String phone;
  final String? description;
  final String expiryDate;
  final String publishDate;
  final int viewCount;
  final bool isAvailable;
  final ProductMerchantSummary merchant;
  final String? primaryImageUrl;
  final int imageCount;
  final List<ProductImageModel> images;
  final bool isFavorited;
  final String createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.phone,
    this.description,
    required this.expiryDate,
    required this.publishDate,
    required this.viewCount,
    required this.isAvailable,
    required this.merchant,
    this.primaryImageUrl,
    this.imageCount = 0,
    this.images = const [],
    this.isFavorited = false,
    required this.createdAt,
  });

  ProductModel copyWith({
    bool? isFavorited,
    int? viewCount,
  }) {
    return ProductModel(
      id: id,
      name: name,
      price: price,
      phone: phone,
      description: description,
      expiryDate: expiryDate,
      publishDate: publishDate,
      viewCount: viewCount ?? this.viewCount,
      isAvailable: isAvailable,
      merchant: merchant,
      primaryImageUrl: primaryImageUrl,
      imageCount: imageCount,
      images: images,
      isFavorited: isFavorited ?? this.isFavorited,
      createdAt: createdAt,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = (json['images'] as List?) ?? const [];
    final parsedImages = rawImages
        .whereType<Map>()
        .map((e) => ProductImageModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    String? primaryUrl = json['primaryImageUrl']?.toString();
    if ((primaryUrl == null || primaryUrl.isEmpty) && parsedImages.isNotEmpty) {
      final primary = parsedImages.where((img) => img.isPrimary).toList();
      primaryUrl = primary.isNotEmpty ? primary.first.url : parsedImages.first.url;
    }

    final rawMerchant = json['merchant'];
    final merchantSummary = rawMerchant is Map
        ? ProductMerchantSummary.fromJson(Map<String, dynamic>.from(rawMerchant))
        : const ProductMerchantSummary(id: '');

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: _toDouble(json['price']),
      phone: (json['phone'] ?? '').toString(),
      description: json['description']?.toString(),
      expiryDate: (json['expiryDate'] ?? '').toString(),
      publishDate: (json['publishDate'] ?? '').toString(),
      viewCount: _toInt(json['viewCount']),
      isAvailable: _toBool(json['isAvailable'], true),
      merchant: merchantSummary,
      primaryImageUrl: primaryUrl,
      imageCount: json['imageCount'] != null ? _toInt(json['imageCount']) : parsedImages.length,
      images: parsedImages,
      isFavorited: _toBool(json['isFavorited']),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}

class RatingItemModel {
  final String id;
  final int score;
  final String userName;
  final String createdAt;

  const RatingItemModel({
    required this.id,
    required this.score,
    required this.userName,
    required this.createdAt,
  });

  factory RatingItemModel.fromJson(Map<String, dynamic> json) {
    return RatingItemModel(
      id: (json['id'] ?? '').toString(),
      score: _toInt(json['score']),
      userName: (json['userName'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}

class RatingListResponse {
  final List<RatingItemModel> items;
  final double average;
  final int total;

  const RatingListResponse({
    required this.items,
    required this.average,
    required this.total,
  });

  factory RatingListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return RatingListResponse(
      items: rawItems
          .whereType<Map>()
          .map((e) => RatingItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      average: _toDouble(json['average']),
      total: _toInt(json['total']),
    );
  }
}

class FollowItemModel {
  final String id;
  final MerchantModel merchant;
  final String createdAt;

  const FollowItemModel({
    required this.id,
    required this.merchant,
    required this.createdAt,
  });

  factory FollowItemModel.fromJson(Map<String, dynamic> json) {
    final rawMerchant = json['merchant'];
    return FollowItemModel(
      id: (json['id'] ?? '').toString(),
      merchant: rawMerchant is Map
          ? MerchantModel.fromJson(Map<String, dynamic>.from(rawMerchant))
          : const MerchantModel(id: '', userId: ''),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}

class NotificationItemModel {
  final String id;
  final String type;
  final String message;
  final String? productId;
  final String merchantId;
  final String? merchantName;
  final String? merchantLogoUrl;
  final bool isRead;
  final String createdAt;

  const NotificationItemModel({
    required this.id,
    required this.type,
    required this.message,
    this.productId,
    required this.merchantId,
    this.merchantName,
    this.merchantLogoUrl,
    required this.isRead,
    required this.createdAt,
  });

  NotificationItemModel copyWith({bool? isRead}) {
    return NotificationItemModel(
      id: id,
      type: type,
      message: message,
      productId: productId,
      merchantId: merchantId,
      merchantName: merchantName,
      merchantLogoUrl: merchantLogoUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      productId: json['productId']?.toString(),
      merchantId: (json['merchantId'] ?? '').toString(),
      merchantName: json['merchantName']?.toString(),
      merchantLogoUrl: json['merchantLogoUrl']?.toString(),
      isRead: _toBool(json['isRead']),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}

class GovStatModel {
  final String governorateId;
  final String governorateName;
  final String governorateNameAr;
  final String governorateNameFr;
  final int count;

  const GovStatModel({
    required this.governorateId,
    required this.governorateName,
    required this.governorateNameAr,
    required this.governorateNameFr,
    required this.count,
  });

  String localizedName(String locale) => locale == 'ar'
      ? (governorateNameAr.isNotEmpty ? governorateNameAr : governorateName)
      : (governorateNameFr.isNotEmpty ? governorateNameFr : governorateName);

  factory GovStatModel.fromJson(Map<String, dynamic> json) {
    final name = (json['governorateName'] ?? '').toString();
    return GovStatModel(
      governorateId: (json['governorateId'] ?? '').toString(),
      governorateName: name,
      governorateNameAr: (json['governorateNameAr'] ?? name).toString(),
      governorateNameFr: (json['governorateNameFr'] ?? name).toString(),
      count: _toInt(json['count']),
    );
  }
}

class DelStatModel {
  final String delegationId;
  final String delegationName;
  final String delegationNameAr;
  final String delegationNameFr;
  final String governorateId;
  final int count;

  const DelStatModel({
    required this.delegationId,
    required this.delegationName,
    required this.delegationNameAr,
    required this.delegationNameFr,
    required this.governorateId,
    required this.count,
  });

  String localizedName(String locale) => locale == 'ar'
      ? (delegationNameAr.isNotEmpty ? delegationNameAr : delegationName)
      : (delegationNameFr.isNotEmpty ? delegationNameFr : delegationName);

  factory DelStatModel.fromJson(Map<String, dynamic> json) {
    final name = (json['delegationName'] ?? '').toString();
    return DelStatModel(
      delegationId: (json['delegationId'] ?? '').toString(),
      delegationName: name,
      delegationNameAr: (json['delegationNameAr'] ?? name).toString(),
      delegationNameFr: (json['delegationNameFr'] ?? name).toString(),
      governorateId: (json['governorateId'] ?? '').toString(),
      count: _toInt(json['count']),
    );
  }
}

class VisitorStatsSummary {
  final int totalVisitors;
  final List<GovStatModel> byGovernorate;
  final List<DelStatModel> byDelegation;

  const VisitorStatsSummary({
    required this.totalVisitors,
    required this.byGovernorate,
    required this.byDelegation,
  });

  factory VisitorStatsSummary.fromJson(Map<String, dynamic> json) {
    final rawGovs = (json['byGovernorate'] as List?) ?? const [];
    final rawDels = (json['byDelegation'] as List?) ?? const [];
    return VisitorStatsSummary(
      totalVisitors: _toInt(json['totalVisitors']),
      byGovernorate: rawGovs
          .whereType<Map>()
          .map((e) => GovStatModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      byDelegation: rawDels
          .whereType<Map>()
          .map((e) => DelStatModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class NearestLocationResult {
  final GovernorateModel governorate;
  final DelegationModel? delegation;

  const NearestLocationResult({
    required this.governorate,
    this.delegation,
  });

  factory NearestLocationResult.fromJson(Map<String, dynamic> json) {
    final rawGov = json['governorate'];
    final rawDel = json['delegation'];
    return NearestLocationResult(
      governorate: rawGov is Map
          ? GovernorateModel.fromJson(Map<String, dynamic>.from(rawGov))
          : const GovernorateModel(id: '', name: '', nameAr: '', nameFr: ''),
      delegation: rawDel is Map
          ? DelegationModel.fromJson(Map<String, dynamic>.from(rawDel))
          : null,
    );
  }
}

class PaginatedList<T> {
  final List<T> items;
  final int total;
  final int page;
  final int totalPages;

  const PaginatedList({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItemJson,
  ) {
    final rawItems = (json['items'] as List?) ?? const [];
    final items = rawItems
        .whereType<Map>()
        .map((e) => fromItemJson(Map<String, dynamic>.from(e)))
        .toList();
    return PaginatedList<T>(
      items: items,
      total: _toInt(json['total'], items.length),
      page: _toInt(json['page'], 1),
      totalPages: _toInt(json['totalPages'], 1),
    );
  }
}
