import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/filter_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/dashboard_screen.dart';
import 'package:hwenti_flutter/screens/merchant_setup_screen.dart';
import 'package:hwenti_flutter/screens/product/add_product_screen.dart';
import 'package:hwenti_flutter/screens/product/edit_product_screen.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';
import 'package:hwenti_flutter/widgets/product_card.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  MerchantModel? _merchant;
  List<ProductModel> _myProducts = [];
  bool _loadingMerchant = false;
  bool _showMyProducts = true;

  int _lastTabIndex = 0;
  FilterProvider? _filterRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMerchantData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final filter = context.read<FilterProvider>();
    if (_filterRef != filter) {
      _filterRef?.removeListener(_onTabChanged);
      _filterRef = filter;
      _lastTabIndex = filter.currentTabIndex;
      _filterRef!.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    _filterRef?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted || _filterRef == null) return;
    final current = _filterRef!.currentTabIndex;
    if (current == 4 && _lastTabIndex != 4) {
      _loadMerchantData();
    }
    _lastTabIndex = current;
  }

  Future<void> _loadMerchantData() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isMerchant) return;

    setState(() => _loadingMerchant = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.getMerchantMe().catchError(
              (_) => const MerchantModel(id: '', userId: ''),
            ),
        ApiClient.instance.getMyProducts(limit: 50).catchError(
              (_) => const PaginatedList<ProductModel>(
                items: [],
                total: 0,
                page: 1,
                totalPages: 1,
              ),
            ),
      ]);
      if (!mounted) return;
      final merchant = results[0] as MerchantModel;
      final products = results[1] as PaginatedList<ProductModel>;
      setState(() {
        if (merchant.id.isNotEmpty) {
          _merchant = merchant;
        }
        _myProducts = products.items;
        _loadingMerchant = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMerchant = false);
    }
  }

  Future<void> _confirmAndDeleteProduct(ProductModel product) async {
    final locale = context.read<LocaleProvider>();
    final isAr = locale.locale == 'ar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          locale.t('delete'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          isAr
              ? 'هل أنت متأكد من حذف "${product.name}"؟'
              : 'Voulez-vous vraiment supprimer "${product.name}" ?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              locale.t('cancel'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(locale.t('delete')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final previous = List<ProductModel>.from(_myProducts);
    setState(() {
      _myProducts.removeWhere((p) => p.id == product.id);
    });

    try {
      await ApiClient.instance.deleteProduct(product.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _myProducts = previous;
      });
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: BouncyTap(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xs,
          ),
          borderRadius: AppRadius.lg,
          backgroundColor: AppColors.surface,
          borderColor: AppColors.borderSubtle,
          shadows: AppShadows.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: accentColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String value,
    required String label,
    IconData? icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: Colors.white),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isMerchant = auth.isMerchant;
    final isAr = locale.locale == 'ar';

    final hasMerchantLogo = _merchant?.logoUrl != null &&
        _merchant!.logoUrl!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            HwentiHeader(title: locale.t('profile')),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: _loadMerchantData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    120,
                  ),
                  children: [
                    // 1. Clean White Bento Profile Header Card + Royal Indigo Stats Strip
                    FadeSlideEntry(
                      index: 0,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        borderRadius: AppRadius.xl,
                        backgroundColor: AppColors.surface,
                        borderColor: AppColors.borderSubtle,
                        shadows: AppShadows.card,
                        child: Column(
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.goldHero,
                                boxShadow: AppShadows.goldGlow,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceElevated,
                                  image: hasMerchantLogo
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            _merchant!.logoUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: !hasMerchantLogo
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 46,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm + 2),
                            Text(
                              user?.name ??
                                  (isAr ? 'زائر حوانتي' : 'Visiteur Hwenti'),
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              user?.email ??
                                  (isAr
                                      ? 'سجّل دخولك لحفظ المفضلة ومتابعة المتاجر'
                                      : 'Connectez-vous pour enregistrer vos favoris'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm + 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs + 1,
                              ),
                              decoration: BoxDecoration(
                                gradient: isMerchant
                                    ? AppGradients.emeraldAction
                                    : AppGradients.goldHero,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isMerchant
                                        ? Icons.storefront_rounded
                                        : Icons.verified_user_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    !auth.isAuthenticated
                                        ? (isAr ? 'وضع الزائر' : 'Mode Invité')
                                        : (isMerchant
                                            ? locale.t('merchant')
                                            : locale.t('visitor')),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Royal Indigo 3-Metric Summary Strip for Merchants
                            if (isMerchant) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm + 4,
                                  horizontal: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.goldHero,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  boxShadow: AppShadows.goldGlow,
                                ),
                                child: Row(
                                  children: [
                                    _buildMetricColumn(
                                      value: '${_myProducts.length}',
                                      label: locale.t('myProducts'),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 28,
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                    _buildMetricColumn(
                                      value: (_merchant?.averageRating ?? 0.0)
                                          .toStringAsFixed(1),
                                      label: locale.t('reviews'),
                                      icon: Icons.star_rounded,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 28,
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                    _buildMetricColumn(
                                      value: _merchant != null &&
                                              _merchant!
                                                  .localizedGov(locale.locale)
                                                  .isNotEmpty
                                          ? _merchant!.localizedGov(
                                              locale.locale,
                                            )
                                          : '-',
                                      label: locale.t('governorate'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // 2. Quick Actions Row
                    FadeSlideEntry(
                      index: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          children: [
                            if (isMerchant) ...[
                              _buildQuickActionTile(
                                icon: Icons.storefront_rounded,
                                label: locale.t('editShop'),
                                accentColor: AppColors.primary,
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const MerchantSetupScreen(
                                        isEdit: true,
                                      ),
                                    ),
                                  );
                                  if (mounted) {
                                    _loadMerchantData();
                                  }
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _buildQuickActionTile(
                                icon: Icons.add_box_rounded,
                                label: locale.t('addProduct'),
                                accentColor: AppColors.action,
                                onTap: () async {
                                  final added =
                                      await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => const AddProductScreen(),
                                    ),
                                  );
                                  if (added == true && mounted) {
                                    _loadMerchantData();
                                  }
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            _buildQuickActionTile(
                              icon: Icons.bar_chart_rounded,
                              label: locale.t('stats'),
                              accentColor: AppColors.secondary,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. White Merchant Storefront Details Card & My Products Showcase
                    if (isMerchant) ...[
                      if (_loadingMerchant && _merchant == null)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (_merchant != null)
                        FadeSlideEntry(
                          index: 2,
                          child: GlassContainer(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            borderRadius: AppRadius.lg,
                            backgroundColor: AppColors.surface,
                            borderColor: AppColors.borderSubtle,
                            shadows: AppShadows.card,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            TradeTypes.icon(
                                              _merchant!.tradeType,
                                            ),
                                            color: AppColors.primary,
                                            size: 22,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Text(
                                              _merchant!.shopName ??
                                                  locale.t('shopName'),
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    BouncyTap(
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const MerchantSetupScreen(
                                              isEdit: true,
                                            ),
                                          ),
                                        );
                                        if (mounted) {
                                          _loadMerchantData();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm + 2,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.full,
                                          ),
                                        ),
                                        child: Text(
                                          locale.t('edit'),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: AppColors.borderSubtle,
                                  height: AppSpacing.lg,
                                ),
                                _buildInfoRow(
                                  icon: TradeTypes.icon(_merchant!.tradeType),
                                  label: locale.t('tradeType'),
                                  value: TradeTypes.label(
                                    _merchant!.tradeType,
                                    locale.locale,
                                  ),
                                ),
                                _buildInfoRow(
                                  icon: Icons.location_city_rounded,
                                  label: locale.t('governorate'),
                                  value: _merchant!.localizedGov(locale.locale),
                                ),
                                _buildInfoRow(
                                  icon: Icons.place_rounded,
                                  label: locale.t('delegation'),
                                  value: _merchant!.localizedDel(locale.locale),
                                ),
                                _buildInfoRow(
                                  icon: Icons.phone_rounded,
                                  label: locale.t('phone'),
                                  value: _merchant!.phone ?? '',
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Expandable My Products Showcase Header
                      FadeSlideEntry(
                        index: 3,
                        child: BouncyTap(
                          onTap: () => setState(
                            () => _showMyProducts = !_showMyProducts,
                          ),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            borderRadius: AppRadius.lg,
                            backgroundColor: AppColors.surface,
                            borderColor: AppColors.borderSubtle,
                            shadows: AppShadows.card,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    '${locale.t('myProducts')} (${_myProducts.length})',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _showMyProducts
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (_showMyProducts)
                        if (_myProducts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Text(
                              locale.t('noProducts'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ..._myProducts.map(
                            (item) => ProductCard(
                              product: item,
                              margin: const EdgeInsets.only(
                                top: AppSpacing.sm + 2,
                              ),
                              footerActions: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  BouncyTap(
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EditProductScreen(
                                            productId: item.id,
                                          ),
                                        ),
                                      );
                                      if (mounted) {
                                        _loadMerchantData();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.xs + 2,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.goldHero,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.edit_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            locale.t('edit'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  BouncyTap(
                                    onTap: () =>
                                        _confirmAndDeleteProduct(item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.xs + 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                        border: Border.all(
                                          color: AppColors.error.withValues(
                                            alpha: 0.45,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 14,
                                            color: AppColors.error,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            locale.t('delete'),
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 12,
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
                          ),
                    ],

                    const SizedBox(height: AppSpacing.xs),

                    // 4. Language Switcher Card (عربي / Français Segmented Toggle)
                    FadeSlideEntry(
                      index: 4,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        borderRadius: AppRadius.lg,
                        backgroundColor: AppColors.surface,
                        borderColor: AppColors.borderSubtle,
                        shadows: AppShadows.card,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: const Icon(
                                Icons.language_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                isAr ? 'اللغة' : 'Langue',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BouncyTap(
                                    onTap: () => locale.setLocale('ar'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAr
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                      ),
                                      child: Text(
                                        'عربي',
                                        style: TextStyle(
                                          color: isAr
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  BouncyTap(
                                    onTap: () => locale.setLocale('fr'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !isAr
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                      ),
                                      child: Text(
                                        'Français',
                                        style: TextStyle(
                                          color: !isAr
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 5. Logout / Sign-In Button
                    FadeSlideEntry(
                      index: 5,
                      child: BouncyTap(
                        onTap: () => auth.logout(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            gradient: !auth.isAuthenticated
                                ? AppGradients.goldHero
                                : null,
                            color: auth.isAuthenticated
                                ? AppColors.error.withValues(alpha: 0.08)
                                : null,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: auth.isAuthenticated
                                ? Border.all(
                                    color:
                                        AppColors.error.withValues(alpha: 0.45),
                                    width: 1.5,
                                  )
                                : null,
                            boxShadow: !auth.isAuthenticated
                                ? AppShadows.goldGlow
                                : const [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                auth.isAuthenticated
                                    ? Icons.logout_rounded
                                    : Icons.login_rounded,
                                size: 20,
                                color: auth.isAuthenticated
                                    ? AppColors.error
                                    : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                auth.isAuthenticated
                                    ? locale.t('logout')
                                    : locale.t('login'),
                                style: TextStyle(
                                  color: auth.isAuthenticated
                                      ? AppColors.error
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
