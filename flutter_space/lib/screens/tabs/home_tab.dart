import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/filter_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/auth/login_screen.dart';
import 'package:hwenti_flutter/screens/product/add_product_screen.dart';
import 'package:hwenti_flutter/screens/product/product_detail_screen.dart';
import 'package:hwenti_flutter/widgets/kinetic_fx.dart';
import 'package:hwenti_flutter/widgets/product_card.dart';
import 'package:hwenti_flutter/widgets/shimmer_skeleton.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<ProductModel> _products = [];
  bool _isLoading = true;
  NearestLocationResult? _detectedLocation;

  String? _lastFilterSignature;
  int _lastTabIndex = 0;
  FilterProvider? _filterRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndTrack();
      _loadProducts(showSkeleton: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final filter = context.read<FilterProvider>();
    if (_filterRef != filter) {
      _filterRef?.removeListener(_onFilterChanged);
      _filterRef = filter;
      _lastFilterSignature = _computeFilterSignature(filter);
      _lastTabIndex = filter.currentTabIndex;
      _filterRef!.addListener(_onFilterChanged);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _filterRef?.removeListener(_onFilterChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _computeFilterSignature(FilterProvider f) {
    return '${f.governorateId ?? ''}|${f.delegationId ?? ''}|${f.tradeType ?? ''}|${f.merchantId ?? ''}|${f.searchQuery}';
  }

  void _onFilterChanged() {
    if (!mounted || _filterRef == null) return;
    final filter = _filterRef!;
    final sig = _computeFilterSignature(filter);
    final tabIdx = filter.currentTabIndex;

    final filtersChanged = sig != _lastFilterSignature;
    final switchedToHome = tabIdx == 0 && _lastTabIndex != 0;

    _lastFilterSignature = sig;
    _lastTabIndex = tabIdx;

    if (filtersChanged || switchedToHome) {
      _loadProducts(showSkeleton: filtersChanged && _products.isEmpty);
    }
  }

  Future<void> _initLocationAndTrack() async {
    double lat = 36.8065; // Fallback: Tunis center
    double lng = 10.1815;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 5),
            ),
          );
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }
    } catch (_) {
      // Graceful fallback on simulator / web / permission denied
    }

    NearestLocationResult? nearest;
    try {
      nearest = await ApiClient.instance.findNearestLocation(lat, lng);
      if (mounted && nearest.governorate.id.isNotEmpty) {
        setState(() {
          _detectedLocation = nearest;
        });
      }
    } catch (_) {}

    try {
      await ApiClient.instance.trackVisitor(
        governorateId: nearest?.governorate.id,
        delegationId: nearest?.delegation?.id,
        latitude: lat,
        longitude: lng,
      );
    } catch (_) {}
  }

  Future<void> _loadProducts({
    bool showSkeleton = false,
    bool forceRefresh = false,
  }) async {
    if (!mounted) return;
    final filter = context.read<FilterProvider>();
    final search = _searchController.text.trim().isNotEmpty
        ? _searchController.text.trim()
        : (filter.searchQuery.trim().isNotEmpty
            ? filter.searchQuery.trim()
            : null);

    // 1. Instant 0ms L1 RAM Cache Hit -> Populate immediately with zero skeleton delay!
    if (!forceRefresh) {
      final cached = ApiClient.instance.getCachedProductsSync(
        governorateId: filter.governorateId,
        delegationId: filter.delegationId,
        tradeType: filter.tradeType,
        merchantId: filter.merchantId,
        search: search,
        available: true,
        limit: 50,
      );
      if (cached != null && cached.items.isNotEmpty) {
        setState(() {
          _products = cached.items;
          _isLoading = false;
        });
      } else if (showSkeleton) {
        setState(() {
          _isLoading = true;
        });
      }
    }

    try {
      final res = await ApiClient.instance.getProducts(
        governorateId: filter.governorateId,
        delegationId: filter.delegationId,
        tradeType: filter.tradeType,
        merchantId: filter.merchantId,
        search: search,
        available: true,
        limit: 50,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _products = res.items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String productId, bool currentIsFavorited) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted || !context.read<AuthProvider>().isAuthenticated) return;
    }

    setState(() {
      _products = _products
          .map(
            (p) => p.id == productId
                ? p.copyWith(isFavorited: !currentIsFavorited)
                : p,
          )
          .toList();
    });

    try {
      if (currentIsFavorited) {
        await ApiClient.instance.removeFavorite(productId);
      } else {
        await ApiClient.instance.addFavorite(productId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = _products
            .map(
              (p) => p.id == productId
                  ? p.copyWith(isFavorited: currentIsFavorited)
                  : p,
            )
            .toList();
      });
    }
  }

  Future<void> _openAddProduct() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (created == true && mounted) {
      _loadProducts();
    }
  }

  String _buildLocationBannerText(
    LocaleProvider locale,
    FilterProvider filter,
  ) {
    final isAr = locale.locale == 'ar';
    final govName = filter.localizedGovernorateName(locale.locale);
    if (govName != null && govName.isNotEmpty) {
      final del = filter.localizedDelegationName(locale.locale);
      if (del != null && del.isNotEmpty) {
        return '$govName · $del';
      }
      return govName;
    }
    if (_detectedLocation != null &&
        _detectedLocation!.governorate.id.isNotEmpty) {
      final gov = _detectedLocation!.governorate.localizedName(locale.locale);
      final del = _detectedLocation!.delegation?.localizedName(locale.locale);
      if (del != null && del.isNotEmpty) {
        return '$gov · $del';
      }
      return gov;
    }
    return isAr ? 'جميع ولايات تونس' : 'Tous les gouvernorats de Tunisie';
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final filter = context.watch<FilterProvider>();
    final isAr = locale.locale == 'ar';
    final isMerchant = auth.isMerchant;
    final topPad = MediaQuery.of(context).padding.top;

    final filterChips = <_FilterChipItem>[
      _FilterChipItem(
        section: 'governorate',
        icon: Icons.location_city_rounded,
        label: filter.localizedGovernorateName(locale.locale) ??
            locale.t('governorate'),
        active: filter.governorateId != null && filter.governorateId!.isNotEmpty,
      ),
      _FilterChipItem(
        section: 'delegation',
        icon: Icons.place_rounded,
        label: filter.localizedDelegationName(locale.locale) ??
            locale.t('delegation'),
        active: filter.delegationId != null && filter.delegationId!.isNotEmpty,
      ),
      _FilterChipItem(
        section: 'merchant',
        icon: Icons.storefront_rounded,
        label: filter.merchantName ?? locale.t('theMerchant'),
        active: filter.merchantId != null && filter.merchantId!.isNotEmpty,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            // Unified White Header Surface (Brand + Location, Search + Filter, Categories)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x080F172A),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                top: topPad + 10,
                bottom: 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row 1: Stacked Brand + Location on Start | Uniform 38px Actions on End
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 42x42 Brand Squircle
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppGradients.goldHero,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: AppShadows.goldGlow,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Stacked App Title + Full Location Subtitle (Never Truncated!)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => filter.setTabIndex(
                              1,
                              focusSection: 'governorate',
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  locale.t('appName'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        _buildLocationBannerText(
                                          locale,
                                          filter,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 15,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Language Switcher Button (38px height, 12px radius)
                        BouncyTap(
                          onTap: locale.toggleLocale,
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.language_rounded,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isAr ? 'FR' : 'AR',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Merchant Add Product Button (38px height, 12px radius)
                        if (isMerchant) ...[
                          const SizedBox(width: 8),
                          BouncyTap(
                            onTap: _openAddProduct,
                            child: ShimmerSheenWrapper(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 38,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.emeraldAction,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: AppShadows.emeraldGlow,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add_rounded,
                                      size: 17,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isAr ? 'إضافة' : 'Ajouter',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Row 2: 48px Squircle Search Bar + 48x48 Squircle Filter Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textInputAction: TextInputAction.search,
                                    onChanged: (value) {
                                      setState(() {});
                                      _searchDebounce?.cancel();
                                      _searchDebounce = Timer(
                                        const Duration(milliseconds: 280),
                                        () {
                                          if (mounted) {
                                            filter.setSearchQuery(value);
                                          }
                                        },
                                      );
                                    },
                                    onSubmitted: (_) => _loadProducts(),
                                    decoration: InputDecoration(
                                      hintText: locale.t('search'),
                                      hintStyle: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() {});
                                      filter.setSearchQuery('');
                                      _loadProducts();
                                    },
                                    child: const Icon(
                                      Icons.cancel_rounded,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        BouncyTap(
                          onTap: () => filter.setTabIndex(1),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: filter.hasActiveFilters
                                  ? AppColors.primary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: filter.hasActiveFilters
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: filter.hasActiveFilters
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Row 3: Integrated Category Scroller (20px edge alignment, 38px pill height)
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // "All / Tout" Pill
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: BouncyTap(
                            onTap: () => filter.setTradeType(null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: filter.tradeType == null
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: filter.tradeType == null
                                      ? AppColors.primary
                                      : AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 15,
                                    color: filter.tradeType == null
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isAr ? 'الكل' : 'Tout',
                                    style: TextStyle(
                                      color: filter.tradeType == null
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 8 TradeTypes Pills
                        ...TradeTypes.all.map((tt) {
                          final selected = filter.tradeType == tt;
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: BouncyTap(
                              onTap: () =>
                                  filter.setTradeType(selected ? null : tt),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.borderSubtle,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      TradeTypes.icon(tt),
                                      size: 15,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      TradeTypes.label(tt, locale.locale),
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Clean Results Summary + Active Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_offer_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isAr
                              ? '${_products.length} عرض متوفر'
                              : '${_products.length} offres disponibles',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (filter.hasActiveFilters)
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...filterChips.where((c) => c.active).map((chip) {
                              return Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 6),
                                child: BouncyTap(
                                  onTap: () => filter.setTabIndex(
                                    1,
                                    focusSection: chip.section,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.full,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          chip.icon,
                                          size: 13,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          chip.label,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  if (filter.hasActiveFilters)
                    BouncyTap(
                      onTap: () {
                        _searchController.clear();
                        filter.clearAll();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              locale.t('clear'),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 4. Spacious Product Feed
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () =>
                    _loadProducts(showSkeleton: false, forceRefresh: true),
                child: _isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xs,
                          bottom: 32,
                        ),
                        itemCount: 3,
                        itemBuilder: (_, __) => const ProductCardSkeleton(),
                      )
                    : _products.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            children: [
                              const SizedBox(height: 36),
                              GlassContainer(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                borderRadius: AppRadius.xl,
                                backgroundColor: AppColors.surface,
                                borderColor: AppColors.borderSubtle,
                                shadows: AppShadows.card,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEEF2FF),
                                        shape: BoxShape.circle,
                                      ),
                                    child: const Icon(
                                        Icons.shopping_basket_outlined,
                                        size: 46,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      locale.t('noProducts'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (filter.hasActiveFilters) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      BouncyTap(
                                        onTap: () {
                                          _searchController.clear();
                                          filter.clearAll();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.lg,
                                            vertical: AppSpacing.sm + 2,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: AppGradients.goldHero,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.full,
                                            ),
                                          ),
                                          child: Text(
                                            locale.t('clear'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              top: 4,
                              bottom: 32,
                            ),
                            itemCount: _products.length,
                            itemBuilder: (context, index) {
                              final item = _products[index];
                              return ProductCard(
                                product: item,
                                onToggleFavorite: _toggleFavorite,
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        productId: item.id,
                                      ),
                                    ),
                                  );
                                  if (mounted) {
                                    _loadProducts();
                                  }
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipItem {
  final String section;
  final IconData icon;
  final String label;
  final bool active;

  const _FilterChipItem({
    required this.section,
    required this.icon,
    required this.label,
    required this.active,
  });
}
