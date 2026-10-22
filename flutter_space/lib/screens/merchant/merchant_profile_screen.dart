import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/auth/login_screen.dart';
import 'package:hwenti_flutter/screens/merchant/report_merchant_screen.dart';
import 'package:hwenti_flutter/screens/product/product_detail_screen.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';
import 'package:hwenti_flutter/widgets/product_card.dart';

class MerchantProfileScreen extends StatefulWidget {
  final String merchantId;

  const MerchantProfileScreen({
    super.key,
    required this.merchantId,
  });

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  static const Color _amberStar = Color(0xFFF59E0B);

  MerchantModel? _merchant;
  List<ProductModel> _products = [];
  List<RatingItemModel> _ratings = [];
  double _avgRating = 0.0;
  int _ratingCount = 0;
  bool _isFollowing = false;
  bool _followBusy = false;
  int _myScore = 0;
  bool _ratingBusy = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (widget.merchantId.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Invalid merchant ID';
      });
      return;
    }

    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final isAuth = context.read<AuthProvider>().isAuthenticated;
      final merchantFuture = ApiClient.instance.getMerchant(widget.merchantId);
      final productsFuture = ApiClient.instance.getProducts(
        merchantId: widget.merchantId,
        limit: 50,
      );
      final ratingsFuture =
          ApiClient.instance.getMerchantRatings(widget.merchantId, limit: 20);

      final merchant = await merchantFuture;
      final productsRes = await productsFuture;

      RatingListResponse? ratingsRes;
      try {
        ratingsRes = await ratingsFuture;
      } catch (_) {}

      bool following = false;
      if (isAuth) {
        try {
          final follows = await ApiClient.instance.getFollows(limit: 100);
          following =
              follows.items.any((f) => f.merchant.id == widget.merchantId);
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _merchant = merchant;
        _products = productsRes.items;
        _ratings = ratingsRes?.items ?? [];
        _avgRating = (ratingsRes != null && ratingsRes.total > 0)
            ? ratingsRes.average
            : merchant.averageRating;
        _ratingCount = (ratingsRes != null && ratingsRes.total > 0)
            ? ratingsRes.total
            : merchant.ratingCount;
        _isFollowing = following;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<bool> _ensureAuthenticated() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) return true;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (!mounted) return false;
    return context.read<AuthProvider>().isAuthenticated;
  }

  Future<void> _toggleFollow() async {
    if (_followBusy || _merchant == null) return;
    final ok = await _ensureAuthenticated();
    if (!ok || !mounted) return;

    final previous = _isFollowing;
    HapticFeedback.lightImpact();
    setState(() {
      _isFollowing = !previous;
      _followBusy = true;
    });

    try {
      if (previous) {
        await ApiClient.instance.unfollowMerchant(widget.merchantId);
      } else {
        await ApiClient.instance.followMerchant(widget.merchantId);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFollowing = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _followBusy = false;
        });
      }
    }
  }

  Future<void> _submitRating(int score) async {
    if (_ratingBusy || _merchant == null) return;
    final ok = await _ensureAuthenticated();
    if (!ok || !mounted) return;

    final previous = _myScore;
    HapticFeedback.selectionClick();
    setState(() {
      _myScore = score;
      _ratingBusy = true;
    });

    try {
      await ApiClient.instance.rateMerchant(widget.merchantId, score);
      await _loadData(silent: true);
      if (!mounted) return;
      final isAr = context.read<LocaleProvider>().locale == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? 'تم إرسال تقييمك بنجاح' : 'Votre évaluation a été enregistrée',
          ),
          backgroundColor: AppColors.action,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _myScore = previous;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _ratingBusy = false;
        });
      }
    }
  }

  Future<void> _toggleProductFavorite(
    String productId,
    bool currentIsFavorited,
  ) async {
    final ok = await _ensureAuthenticated();
    if (!ok || !mounted) return;

    HapticFeedback.lightImpact();
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

  Future<void> _callMerchant() async {
    final rawPhone = _merchant?.phone?.trim() ?? '';
    final phone = rawPhone.replaceAll(RegExp(r'\s+'), '');
    if (phone.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  String _formatReviewDate(String raw, String localeCode) {
    if (raw.trim().isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    try {
      return DateFormat('yyyy/MM/dd', localeCode == 'ar' ? 'ar' : 'fr')
          .format(dt.toLocal());
    } catch (_) {
      final local = dt.toLocal();
      return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final shopTitle = (_merchant?.shopName?.trim().isNotEmpty ?? false)
        ? _merchant!.shopName!.trim()
        : locale.t('theMerchant');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            HwentiHeader(
              title: shopTitle,
              showBack: true,
            ),
            Expanded(
              child: _buildBody(locale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LocaleProvider locale) {
    final isAr = locale.locale == 'ar';

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null || _merchant == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error ?? locale.t('error'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BouncyTap(
                  onTap: _loadData,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.goldHero,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      locale.t('retry'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final merchant = _merchant!;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => _loadData(silent: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideEntry(
              index: 0,
              child: _buildStorefrontHeroBento(merchant, locale, isAr),
            ),
            const SizedBox(height: AppSpacing.md),
            FadeSlideEntry(
              index: 1,
              child: _buildRatingSection(locale, isAr),
            ),
            if (_ratings.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              FadeSlideEntry(
                index: 2,
                child: _buildReviewsSection(locale),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    locale.t('merchantProducts'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '${_products.length}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_products.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 44,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locale.t('noProducts'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_products.length, (index) {
                final product = _products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: FadeSlideEntry(
                    index: index + 3,
                    child: ProductCard(
                      product: product,
                      margin: EdgeInsets.zero,
                      onToggleFavorite: _toggleProductFavorite,
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  productId: product.id,
                                ),
                              ),
                            )
                            .then((_) => _loadData(silent: true));
                      },
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStorefrontHeroBento(
    MerchantModel merchant,
    LocaleProvider locale,
    bool isAr,
  ) {
    final shopName = (merchant.shopName?.trim().isNotEmpty ?? false)
        ? merchant.shopName!.trim()
        : locale.t('theMerchant');
    final logoUrl = merchant.logoUrl?.trim() ?? '';
    final tradeLabel = TradeTypes.label(merchant.tradeType, locale.locale);
    final gov = merchant.localizedGov(locale.locale);
    final del = merchant.localizedDel(locale.locale);
    final locationParts =
        [gov, del].where((s) => s.trim().isNotEmpty).join(' • ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Royal Indigo Hero Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              gradient: AppGradients.goldHero,
            ),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: AppShadows.card,
                  ),
                  child: ClipOval(
                    child: logoUrl.isNotEmpty
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.storefront_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.storefront_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  shopName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    if (tradeLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              TradeTypes.icon(merchant.tradeType),
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              tradeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (locationParts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locationParts,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 3-Column KPI Strip + Actions inside clean white surface
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiBox(
                        value: '${_avgRating.toStringAsFixed(1)} ★',
                        label: locale.t('reviews'),
                        valueColor: _amberStar,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiBox(
                        value: '${_products.length}',
                        label: isAr ? 'المنتجات' : 'Produits',
                        valueColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildKpiBox(
                        value: '$_ratingCount',
                        label: isAr ? 'عدد التقييمات' : 'Avis clients',
                        valueColor: AppColors.action,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: BouncyTap(
                        onTap: _followBusy ? null : _toggleFollow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: _isFollowing
                                ? AppGradients.tiffanyGlow
                                : AppGradients.goldHero,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: AppShadows.goldGlow,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isFollowing
                                    ? Icons.notifications_active_rounded
                                    : Icons.person_add_alt_1_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isFollowing
                                    ? locale.t('unfollow')
                                    : locale.t('follow'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if ((merchant.phone?.trim().isNotEmpty ?? false)) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: BouncyTap(
                          onTap: _callMerchant,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: AppGradients.emeraldAction,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppShadows.emeraldGlow,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.phone_in_talk_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  locale.t('call'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    BouncyTap(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReportMerchantScreen(
                              merchantId: merchant.id,
                              merchantName: merchant.shopName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.flag_outlined,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBox({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(LocaleProvider locale, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            locale.t('rateMerchant'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'اضغط على النجوم لتقييم هذا المتجر'
                : 'Touchez les étoiles pour noter ce marchand',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (idx) {
              final star = idx + 1;
              final active = star <= _myScore;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: BouncyTap(
                  onTap: _ratingBusy ? null : () => _submitRating(star),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? _amberStar.withValues(alpha: 0.14)
                          : AppColors.surfaceElevated,
                      border: Border.all(
                        color: active ? _amberStar : AppColors.borderSubtle,
                      ),
                    ),
                    child: Icon(
                      active
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 28,
                      color: active ? _amberStar : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(LocaleProvider locale) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.t('reviews'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._ratings.take(8).map((item) {
            final initial = item.userName.trim().isNotEmpty
                ? item.userName.trim()[0].toUpperCase()
                : '★';
            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.userName.isNotEmpty
                              ? item.userName
                              : locale.t('visitor'),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          _formatReviewDate(item.createdAt, locale.locale),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < item.score
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 15,
                        color: _amberStar,
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
