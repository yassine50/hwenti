import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/cache/cached_image.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/auth/login_screen.dart';
import 'package:hwenti_flutter/screens/merchant/merchant_profile_screen.dart';
import 'package:hwenti_flutter/screens/merchant/report_merchant_screen.dart';
import 'package:hwenti_flutter/screens/product/edit_product_screen.dart';
import 'package:hwenti_flutter/widgets/kinetic_fx.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color _amberStar = Color(0xFFF59E0B);

  final PageController _pageController = PageController();

  ProductModel? _product;
  bool _isLoading = true;
  String? _error;

  int _currentImageIndex = 0;
  bool _isFavorited = false;
  bool _isTogglingFavorite = false;

  int _selectedRating = 0;
  bool _isSubmittingRating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadProduct(trackView: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct({bool trackView = false, bool silent = false}) async {
    if (!silent) {
      final syncHit = ApiClient.instance.getCachedProductSync(widget.productId);
      if (syncHit != null) {
        setState(() {
          _product = syncHit;
          _isFavorited = syncHit.isFavorited;
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }
    }

    try {
      final product = await ApiClient.instance.getProduct(
        widget.productId,
        forceRefresh: silent,
      );
      if (!mounted) return;
      setState(() {
        _product = product;
        _isFavorited = product.isFavorited;
        _isLoading = false;
        _error = null;
      });

      if (trackView) {
        _incrementViewSilently();
      }
    } catch (e) {
      if (!mounted) return;
      if (_product != null) {
        setState(() => _isLoading = false);
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _incrementViewSilently() async {
    try {
      final updatedCount =
          await ApiClient.instance.incrementProductView(widget.productId);
      if (!mounted || _product == null) return;
      if (updatedCount > _product!.viewCount) {
        setState(() {
          _product = _product!.copyWith(viewCount: updatedCount);
        });
      }
    } catch (_) {}
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

  Future<void> _toggleFavorite() async {
    if (_product == null || _isTogglingFavorite) return;
    final ok = await _ensureAuthenticated();
    if (!ok || !mounted) return;

    final previous = _isFavorited;
    HapticFeedback.lightImpact();
    setState(() {
      _isFavorited = !previous;
      _isTogglingFavorite = true;
    });

    try {
      if (previous) {
        await ApiClient.instance.removeFavorite(_product!.id);
      } else {
        await ApiClient.instance.addFavorite(_product!.id);
      }
      if (!mounted) return;
      final isAr = context.read<LocaleProvider>().locale == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorited
                ? (isAr ? 'تمت الإضافة للمفضلة' : 'Ajouté aux favoris')
                : (isAr ? 'تمت الإزالة من المفضلة' : 'Retiré des favoris'),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFavorited = previous;
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
          _isTogglingFavorite = false;
        });
      }
    }
  }

  Future<void> _submitMerchantRating(int score) async {
    if (_product == null ||
        _product!.merchant.id.isEmpty ||
        _isSubmittingRating) {
      return;
    }
    final ok = await _ensureAuthenticated();
    if (!ok || !mounted) return;

    final previous = _selectedRating;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRating = score;
      _isSubmittingRating = true;
    });

    try {
      await ApiClient.instance.rateMerchant(_product!.merchant.id, score);
      await _loadProduct(silent: true);
      if (!mounted) return;
      final isAr = context.read<LocaleProvider>().locale == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'شكراً لتقييمك لهذا المتجر!'
                : 'Merci pour votre évaluation !',
          ),
          backgroundColor: AppColors.action,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedRating = previous;
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
          _isSubmittingRating = false;
        });
      }
    }
  }

  Future<void> _callSeller() async {
    if (_product == null) return;
    final phone = _product!.phone.replaceAll(RegExp(r'\s+'), '');
    final isAr = context.read<LocaleProvider>().locale == 'ar';
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'رقم الهاتف غير متوفر'
                : 'Numéro de téléphone indisponible',
          ),
        ),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isAr ? 'الاتصال بـ' : 'Appeler'}: $phone'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${isAr ? 'الاتصال بـ' : 'Appeler'}: $phone'),
        ),
      );
    }
  }

  Future<void> _shareProduct() async {
    if (_product == null) return;
    final locale = context.read<LocaleProvider>();
    final isAr = locale.locale == 'ar';
    final p = _product!;
    final priceStr = _formatPrice(p.price);
    final currency = locale.t('tnd');
    final shopName = p.merchant.shopName ?? '';
    final text = isAr
        ? 'اكتشف "${p.name}" بسعر $priceStr $currency${shopName.isNotEmpty ? ' لدى $shopName' : ''} على تطبيق حوانتي (Hwenti)!'
        : 'Découvrez "${p.name}" à $priceStr $currency${shopName.isNotEmpty ? ' chez $shopName' : ''} sur Hwenti !';

    try {
      await Share.share(text, subject: p.name);
    } catch (_) {
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? 'تم نسخ تفاصيل المنتج' : 'Détails du produit copiés',
          ),
        ),
      );
    }
  }

  Future<void> _openEditProduct() async {
    if (_product == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProductScreen(productId: _product!.id),
      ),
    );
    if (updated == true && mounted) {
      await _loadProduct(silent: false);
    }
  }

  Future<void> _confirmAndDeleteProduct() async {
    if (_product == null || _isDeleting) return;
    final locale = context.read<LocaleProvider>();
    final isAr = locale.locale == 'ar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          isAr ? 'حذف المنتج' : 'Supprimer le produit',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          isAr
              ? 'هل أنت متأكد من رغبتك في حذف هذا المنتج نهائياً؟'
              : 'Êtes-vous sûr de vouloir supprimer définitivement ce produit ?',
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

    setState(() => _isDeleting = true);
    try {
      await ApiClient.instance.deleteProduct(_product!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'تم حذف المنتج بنجاح'
                : 'Produit supprimé avec succès',
          ),
          backgroundColor: AppColors.action,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  String _formatDate(String raw, String localeCode) {
    if (raw.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    try {
      return DateFormat('dd/MM/yyyy', localeCode == 'ar' ? 'ar' : 'fr')
          .format(parsed.toLocal());
    } catch (_) {
      final local = parsed.toLocal();
      return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    }
  }

  int? _remainingDays(String rawExpiry) {
    final expiry = DateTime.tryParse(rawExpiry);
    if (expiry == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final localExp = expiry.toLocal();
    final expDay = DateTime(localExp.year, localExp.month, localExp.day);
    return expDay.difference(today).inDays;
  }

  List<String> _extractImageUrls(ProductModel product) {
    final sorted = [...product.images]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final urls = sorted
        .map((img) => img.url.trim())
        .where((u) => u.isNotEmpty)
        .toList();
    if (urls.isEmpty &&
        product.primaryImageUrl != null &&
        product.primaryImageUrl!.trim().isNotEmpty) {
      urls.add(product.primaryImageUrl!.trim());
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final isMerchantUser = auth.isMerchant;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: _buildBody(locale, isMerchantUser),
      ),
      bottomNavigationBar: _product != null
          ? _buildBottomActionDock(locale, isMerchantUser)
          : null,
    );
  }

  Widget _buildBody(LocaleProvider locale, bool isMerchantUser) {
    final isAr = locale.locale == 'ar';

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null || _product == null) {
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 34,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error ??
                      (isAr
                          ? 'تعذر تحميل تفاصيل المنتج'
                          : 'Impossible de charger ce produit'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BouncyTap(
                  onTap: () => _loadProduct(trackView: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.goldHero,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppShadows.goldGlow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          locale.t('retry'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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
      );
    }

    final product = _product!;
    final images = _extractImageUrls(product);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => _loadProduct(silent: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroGallery(images, product, locale, isMerchantUser),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideEntry(
                    index: 0,
                    child: _buildEditorialTitleAndPriceCard(product, locale),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if ((product.description ?? '').trim().isNotEmpty) ...[
                    FadeSlideEntry(
                      index: 1,
                      child: _buildDescriptionBentoCard(
                        product.description!.trim(),
                        locale,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (product.merchant.id.isNotEmpty) ...[
                    FadeSlideEntry(
                      index: 2,
                      child: _buildMerchantStorefrontCard(
                        product.merchant,
                        locale,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeSlideEntry(
                      index: 3,
                      child: _buildRatingCard(product, locale),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroGallery(
    List<String> images,
    ProductModel product,
    LocaleProvider locale,
    bool isMerchantUser,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final remDays = _remainingDays(product.expiryDate);
    final isAvailable = product.isAvailable && (remDays == null || remDays >= 0);

    return SizedBox(
      height: 380 + topPadding * 0.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'product-image-${widget.productId}',
            child: images.isEmpty
                ? Container(
                    color: AppColors.surfaceElevated,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            locale.locale == 'ar'
                                ? 'لا توجد صورة للمنتج'
                                : 'Aucune image disponible',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (idx) {
                      setState(() => _currentImageIndex = idx);
                    },
                    itemBuilder: (context, index) {
                      return DoubleTapHeartOverlay(
                        onDoubleTapFavorite: () {
                          if (!_isFavorited) {
                            _toggleFavorite();
                          }
                        },
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 3.0,
                          child: HwentiCachedImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            placeholderBuilder: (_) => Container(
                              color: AppColors.surfaceElevated,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                            errorBuilder: (_) => Container(
                              color: AppColors.surfaceElevated,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 54,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Top floating frosted white navigation bar
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _buildFloatingCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                  color: AppColors.textPrimary,
                ),
                const Spacer(),
                if (isMerchantUser) ...[
                  _buildFloatingCircleButton(
                    icon: Icons.edit_outlined,
                    onTap: _openEditProduct,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildFloatingCircleButton(
                    icon: Icons.delete_outline_rounded,
                    onTap: _isDeleting ? null : _confirmAndDeleteProduct,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                ],
                ParticleHeartButton(
                  isFavorited: _isFavorited,
                  onTap: () {
                    if (!_isTogglingFavorite) _toggleFavorite();
                  },
                  size: 40,
                  iconSize: 20,
                ),
                const SizedBox(width: 4),
                _buildFloatingCircleButton(
                  icon: Icons.ios_share_rounded,
                  onTap: _shareProduct,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),

          // Availability badge & Image Counter pill
          Positioned(
            bottom: images.length > 1 ? 68 : 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvailable ? AppColors.action : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAvailable
                            ? locale.t('available')
                            : locale.t('expired'),
                        style: TextStyle(
                          color: isAvailable
                              ? AppColors.action
                              : AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (images.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentImageIndex + 1} / ${images.length}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Floating White Thumbnail Strip
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: AppShadows.card,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(images.length, (idx) {
                        final isSelected = idx == _currentImageIndex;
                        return BouncyTap(
                          onTap: () {
                            _pageController.animateToPage(
                              idx,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isSelected ? 46 : 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: HwentiCachedImage(
                                imageUrl: images[idx],
                                fit: BoxFit.cover,
                                errorBuilder: (_) => Container(
                                  color: AppColors.surfaceElevated,
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircleButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.card,
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }

  Widget _buildEditorialTitleAndPriceCard(
    ProductModel product,
    LocaleProvider locale,
  ) {
    final isAr = locale.locale == 'ar';
    final remDays = _remainingDays(product.expiryDate);

    String remainingLabel;
    if (remDays == null) {
      remainingLabel = _formatDate(product.expiryDate, locale.locale);
    } else if (remDays >= 0) {
      remainingLabel = isAr ? 'متبقي $remDays يوم' : '$remDays j restants';
    } else {
      remainingLabel = locale.t('expired');
    }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: AppGradients.goldHero,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadows.goldGlow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locale.t('tnd'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.md),

          // 3 Soft-Slate Metric Tiles
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.visibility_outlined,
                  label: locale.t('views'),
                  value: '${product.viewCount}',
                  accentColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.calendar_today_outlined,
                  label: locale.t('publishDate'),
                  value: _formatDate(product.publishDate, locale.locale),
                  accentColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.timer_outlined,
                  label: locale.t('expiryDate'),
                  value: remainingLabel,
                  accentColor: (remDays != null && remDays < 0)
                      ? AppColors.error
                      : AppColors.action,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBentoCard(String description, LocaleProvider locale) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                locale.t('description'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.5,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantStorefrontCard(
    ProductMerchantSummary merchant,
    LocaleProvider locale,
  ) {
    final isAr = locale.locale == 'ar';
    final shopName = (merchant.shopName?.trim().isNotEmpty ?? false)
        ? merchant.shopName!.trim()
        : locale.t('theMerchant');
    final logoUrl = merchant.logoUrl?.trim() ?? '';

    return BouncyTap(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MerchantProfileScreen(merchantId: merchant.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      locale.t('theMerchant'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _amberStar.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: _amberStar,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              merchant.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isAr ? 'زيارة المتجر' : 'Voir la boutique',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(ProductModel product, LocaleProvider locale) {
    final isAr = locale.locale == 'ar';
    return ConfettiBurstWidget(
      trigger: _selectedRating >= 4,
      child: Container(
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
                  ? 'شارك تجربتك وتقييمك لهذا المتجر'
                  : 'Partagez votre note avec la communauté',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final isSelected = starValue <= _selectedRating;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: BouncyTap(
                    onTap: _isSubmittingRating
                        ? null
                        : () => _submitMerchantRating(starValue),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? _amberStar.withValues(alpha: 0.15)
                            : AppColors.surfaceElevated,
                        border: Border.all(
                          color:
                              isSelected ? _amberStar : AppColors.borderSubtle,
                        ),
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 28,
                        color:
                            isSelected ? _amberStar : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionDock(LocaleProvider locale, bool isMerchantUser) {
    final product = _product!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle),
        ),
        boxShadow: AppShadows.card,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: BouncyTap(
              onTap: _callSeller,
              child: ShimmerSheenWrapper(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        locale.t('call'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildDockIconButton(
            icon: _isFavorited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavorited ? AppColors.error : AppColors.textPrimary,
            onTap: _isTogglingFavorite ? null : _toggleFavorite,
            tooltip: locale.t('favorites'),
          ),
          const SizedBox(width: 8),
          _buildDockIconButton(
            icon: Icons.share_outlined,
            color: AppColors.primary,
            onTap: _shareProduct,
            tooltip: locale.t('share'),
          ),
          if (!isMerchantUser && product.merchant.id.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildDockIconButton(
              icon: Icons.flag_outlined,
              color: AppColors.error,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportMerchantScreen(
                      merchantId: product.merchant.id,
                      merchantName: product.merchant.shopName,
                    ),
                  ),
                );
              },
              tooltip: locale.t('report'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDockIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: BouncyTap(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
      ),
    );
  }
}
