import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/filter_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/product/product_detail_screen.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';
import 'package:hwenti_flutter/widgets/product_card.dart';
import 'package:hwenti_flutter/widgets/shimmer_skeleton.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<ProductModel> _favorites = [];
  bool _isLoading = true;
  int _lastTabIndex = 0;
  FilterProvider? _filterRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites(showSkeleton: true);
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
    if (current == 2 && _lastTabIndex != 2) {
      _loadFavorites(showSkeleton: false);
    }
    _lastTabIndex = current;
  }

  Future<void> _loadFavorites({bool showSkeleton = false}) async {
    if (!mounted) return;
    if (showSkeleton) {
      setState(() => _isLoading = true);
    }
    try {
      final res = await ApiClient.instance.getFavorites(limit: 50);
      if (!mounted) return;
      setState(() {
        _favorites = res.items
            .map((item) => item.copyWith(isFavorited: true))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(String productId) async {
    HapticFeedback.mediumImpact();
    final previous = List<ProductModel>.from(_favorites);
    setState(() {
      _favorites.removeWhere((p) => p.id == productId);
    });
    try {
      await ApiClient.instance.removeFavorite(productId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _favorites = previous;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final filter = context.watch<FilterProvider>();
    final isAr = locale.locale == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            HwentiHeader(title: locale.t('favorites')),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () => _loadFavorites(showSkeleton: false),
                child: _isLoading
                    ? ListView.builder(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.sm,
                          bottom: 110,
                        ),
                        itemCount: 3,
                        itemBuilder: (_, __) => const ProductCardSkeleton(),
                      )
                    : _favorites.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            children: [
                              const SizedBox(height: 56),
                              FadeSlideEntry(
                                index: 0,
                                child: GlassContainer(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  borderRadius: AppRadius.xl,
                                  backgroundColor: AppColors.surface,
                                  borderColor: AppColors.borderSubtle,
                                  shadows: AppShadows.card,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(
                                            alpha: 0.12,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.favorite_rounded,
                                          size: 48,
                                          color: AppColors.error,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        locale.t('noFavorites'),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isAr
                                            ? 'احفظ منتجاتك المفضلة للوصول إليها بسرعة'
                                            : 'Enregistrez vos articles favoris pour les retrouver facilement',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      BouncyTap(
                                        onTap: () => filter.setTabIndex(0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xl,
                                            vertical: AppSpacing.sm + 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: AppGradients.goldHero,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.full,
                                            ),
                                            boxShadow: AppShadows.goldGlow,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.explore_rounded,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isAr
                                                    ? 'تصفح المنتجات'
                                                    : 'Explorer',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
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
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sm,
                              bottom: 110,
                            ),
                            itemCount: _favorites.length,
                            itemBuilder: (context, index) {
                              final item = _favorites[index];
                              return FadeSlideEntry(
                                index: index,
                                child: Dismissible(
                                  key: ValueKey<String>('fav_${item.id}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) =>
                                      _removeFromFavorites(item.id),
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                    alignment: AlignmentDirectional.centerEnd,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFEF4444),
                                          Color(0xFFB91C1C),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  child: ProductCard(
                                    product: item,
                                    onToggleFavorite: (id, _) =>
                                        _removeFromFavorites(id),
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            productId: item.id,
                                          ),
                                        ),
                                      );
                                      if (mounted) {
                                        _loadFavorites(showSkeleton: false);
                                      }
                                    },
                                  ),
                                ),
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
