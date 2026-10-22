import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hwenti_flutter/core/cache/cached_image.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/merchant/merchant_profile_screen.dart';
import 'package:hwenti_flutter/screens/product/product_detail_screen.dart';
import 'package:hwenti_flutter/widgets/kinetic_fx.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function? onToggleFavorite;
  final VoidCallback? onTap;
  final Widget? footerActions;
  final EdgeInsetsGeometry? margin;

  const ProductCard({
    super.key,
    required this.product,
    this.onToggleFavorite,
    this.onTap,
    this.footerActions,
    this.margin,
  });

  void _invokeToggleFavorite() {
    final cb = onToggleFavorite;
    if (cb == null) return;
    if (cb is void Function(String, bool)) {
      cb(product.id, product.isFavorited);
    } else if (cb is void Function()) {
      cb();
    } else if (cb is void Function(String)) {
      cb(product.id);
    } else if (cb is void Function(ProductModel)) {
      cb(product);
    } else {
      try {
        Function.apply(cb, [product.id, product.isFavorited]);
      } catch (_) {
        try {
          Function.apply(cb, const []);
        } catch (_) {}
      }
    }
  }

  Future<void> _dialPhone(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) return;
    final uri = Uri.parse('tel:$cleaned');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.locale == 'ar';
    final imageUrl = product.primaryImageUrl;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final shopName = (product.merchant.shopName != null &&
            product.merchant.shopName!.trim().isNotEmpty)
        ? product.merchant.shopName!
        : locale.t('theMerchant');
    final hasMerchantLogo = product.merchant.logoUrl != null &&
        product.merchant.logoUrl!.trim().isNotEmpty;

    return BouncyTap(
      scaleDown: 0.98,
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
      child: Container(
        margin: margin ??
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Framed 4:3 Bento Image
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DoubleTapHeartOverlay(
                        onSingleTap: onTap ??
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                        onDoubleTapFavorite: () {
                          HapticFeedback.mediumImpact();
                          if (!product.isFavorited) {
                            _invokeToggleFavorite();
                          }
                        },
                        child: Hero(
                          tag: 'product-image-${product.id}',
                          child: hasImage
                              ? HwentiCachedImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (_) =>
                                      _buildPlaceholder(),
                                  errorBuilder: (_) => _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                      ),

                      // Top-start: Clean Frosted White Pill with Pulsing Beacon Dot
                      PositionedDirectional(
                        top: 10,
                        start: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xEBFFFFFF),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x140F172A),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PulseBeaconDot(
                                    color: product.isAvailable
                                        ? AppColors.action
                                        : AppColors.error,
                                    size: 6.5,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    product.isAvailable
                                        ? locale.t('available')
                                        : locale.t('expired'),
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate(delay: 120.ms)
                                .fadeIn(duration: 280.ms)
                                .scaleXY(
                                  begin: 0.86,
                                  end: 1.0,
                                  duration: 320.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          ),
                        ),
                      ),

                      // Top-end: Particle Burst Circular Heart Button
                      if (onToggleFavorite != null)
                        PositionedDirectional(
                          top: 4,
                          end: 4,
                          child: ParticleHeartButton(
                            isFavorited: product.isFavorited,
                            onTap: _invokeToggleFavorite,
                            size: 36,
                            iconSize: 19,
                          ),
                        ),

                      // Bottom-end: Dark Translucent Pill with Photo Count
                      if (product.imageCount > 1)
                        PositionedDirectional(
                          bottom: 10,
                          end: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xB30F172A),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo_library_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '1/${product.imageCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
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
            ),

            // Editorial Details Area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Merchant Avatar & Shop Name + Warm Amber Rating Pill
                  Row(
                    children: [
                      Expanded(
                        child: BouncyTap(
                          onTap: product.merchant.id.isNotEmpty
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MerchantProfileScreen(
                                        merchantId: product.merchant.id,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceElevated,
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: hasMerchantLogo
                                      ? HwentiCachedImage(
                                          imageUrl: product.merchant.logoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_) => const Icon(
                                            Icons.storefront_rounded,
                                            size: 13,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.storefront_rounded,
                                          size: 13,
                                          color: AppColors.primary,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  shopName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.merchant.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row 2: Product Title
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Row 3: Price + Currency + Views on Start, Tactile Call Pill Button on End
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              product.price.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locale.t('tnd'),
                              style: const TextStyle(
                                color: Color(0xFF4F46E5),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${product.viewCount}',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (product.phone.trim().isNotEmpty)
                        BouncyTap(
                          onTap: () => _dialPhone(product.phone),
                          child: ShimmerSheenWrapper(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppGradients.goldHero,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                boxShadow: AppShadows.goldGlow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.call_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isAr ? 'اتصل' : 'Appeler',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            if (footerActions != null) ...[
              const Divider(
                height: 1,
                color: AppColors.borderSubtle,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: footerActions!,
              ),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
          .moveY(
            begin: 18,
            end: 0,
            duration: 360.ms,
            curve: Curves.easeOutQuint,
          )
          .scaleXY(
            begin: 0.97,
            end: 1.0,
            duration: 360.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFFFFF),
          ),
          child: const Icon(
            Icons.image_outlined,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
