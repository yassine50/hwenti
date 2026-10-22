import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/widgets/google_sign_in_button.dart';
import 'package:hwenti_flutter/widgets/kinetic_fx.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _floatController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    // Persist immediately on first open so onboarding only ever appears once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().markOnboardingShownOnFirstOpen();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _nextOrFinish(AuthProvider auth) {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      auth.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.read<AuthProvider>();
    final isAr = locale.locale == 'ar';

    final slides = <_SlideSpec>[
      _SlideSpec(
        tag: isAr ? 'تحديد الموقع الذكي' : 'Géolocalisation Intelligente',
        title: isAr
            ? 'اكتشف أفضل حوانت تونس القريبة منك'
            : 'Découvrez les meilleures boutiques près de vous',
        subtitle: isAr
            ? 'تصفح آلاف المنتجات والعروض المحلية في جميع ولايات ومعتمديات تونس الـ 24 بدقة وسهولة.'
            : 'Explorez des milliers de produits locaux dans les 24 gouvernorats et délégations de Tunisie.',
        accentColor: const Color(0xFF4F46E5),
        kind: _IllustrationKind.radar,
      ),
      _SlideSpec(
        tag: isAr ? 'شفافية وتواصل مباشر' : 'Transparence & Contact Direct',
        title: isAr
            ? 'عروض متجددة وتواصل فوري مع التاجر'
            : 'Offres vérifiées & appel direct au marchand',
        subtitle: isAr
            ? 'شاهد صور المنتج الحقيقية، السعر بالدينار التونسي، تقييمات الحرفاء، واتصل بالتاجر بضغطة واحدة.'
            : 'Consultez les photos réelles, les prix en TND, les avis clients et appelez le marchand en un geste.',
        accentColor: const Color(0xFF0D9488),
        kind: _IllustrationKind.showcase,
      ),
      _SlideSpec(
        tag: isAr ? 'للتجار والحرفاء' : 'Pour Marchands & Clients',
        title: isAr
            ? 'افتح متجرك الرقمي وتابع إحصائيات زوارك'
            : 'Lancez votre boutique & suivez vos statistiques',
        subtitle: isAr
            ? 'انشر منتجاتك في ثوانٍ، أضف حتى 6 صور لكل منتج، وتابع زوار متجرك حسب الولاية والمعتمدية.'
            : 'Publiez vos produits en quelques secondes et analysez vos visiteurs par gouvernorat et délégation.',
        accentColor: const Color(0xFF7C3AED),
        kind: _IllustrationKind.analytics,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppGradients.goldHero,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: AppShadows.goldGlow,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          locale.t('appName'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BouncyTap(
                          onTap: locale.toggleLocale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.full),
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
                                  isAr ? 'FR' : 'ع',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        BouncyTap(
                          onTap: auth.completeOnboarding,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              isAr ? 'تخطي' : 'Passer',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Expanded(
                            flex: 6,
                            child: AnimatedBuilder(
                              animation: _floatController,
                              builder: (context, _) {
                                final floatOffset =
                                    math.sin(_floatController.value * math.pi) * 6;
                                return _buildIllustrationCard(
                                  slide: slide,
                                  isAr: isAr,
                                  floatOffset: floatOffset,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: slide.accentColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(
                                    slide.tag,
                                    style: TextStyle(
                                      color: slide.accentColor,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    slide.subtitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      color: AppColors.textSecondary,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Controls + Google Sign-In
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (_currentPage > 0) ...[
                          BouncyTap(
                            onTap: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Icon(
                                isAr
                                    ? Icons.arrow_back_ios_new_rounded
                                    : Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: BouncyTap(
                            onTap: () => _nextOrFinish(auth),
                            child: ShimmerSheenWrapper(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.goldHero,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppShadows.goldGlow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage == slides.length - 1
                                          ? (isAr ? 'ابدأ الآن' : 'Commencer')
                                          : (isAr ? 'التالي' : 'Suivant'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isAr
                                          ? Icons.arrow_back_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const GoogleSignInButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationCard({
    required _SlideSpec slide,
    required bool isAr,
    required double floatOffset,
  }) {
    switch (slide.kind) {
      case _IllustrationKind.radar:
        return _buildRadarIllustration(isAr, floatOffset);
      case _IllustrationKind.showcase:
        return _buildShowcaseIllustration(isAr, floatOffset);
      case _IllustrationKind.analytics:
        return _buildAnalyticsIllustration(isAr, floatOffset);
    }
  }

  Widget _buildRadarIllustration(bool isAr, double floatOffset) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Concentric radar rings
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.10),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.05),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
          ),
          // Center Pin
          Transform.translate(
            offset: Offset(0, -floatOffset),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppGradients.goldHero,
                shape: BoxShape.circle,
                boxShadow: AppShadows.goldGlow,
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          // Floating Governorate Chips
          Positioned(
            top: 26 + floatOffset * 0.6,
            left: 22,
            child: _FloatingBadge(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF4F46E5),
              title: isAr ? 'تونس · المرسى' : 'Tunis · La Marsa',
              subtitle: isAr ? '48 متجر نشط' : '48 boutiques',
            ),
          ),
          Positioned(
            top: 34 - floatOffset * 0.5,
            right: 20,
            child: _FloatingBadge(
              icon: Icons.storefront_rounded,
              iconColor: const Color(0xFF0D9488),
              title: isAr ? 'سوسة' : 'Sousse',
              subtitle: isAr ? '32 عرض جديد' : '32 offres',
            ),
          ),
          Positioned(
            bottom: 24 + floatOffset * 0.5,
            left: 26,
            child: _FloatingBadge(
              icon: Icons.devices_other_rounded,
              iconColor: const Color(0xFF7C3AED),
              title: isAr ? 'صفاقس' : 'Sfax',
              subtitle: isAr ? 'إلكترونيات وملابس' : 'Électronique & Mode',
            ),
          ),
          Positioned(
            bottom: 28 - floatOffset * 0.6,
            right: 22,
            child: _FloatingBadge(
              icon: Icons.verified_rounded,
              iconColor: const Color(0xFFD97706),
              title: isAr ? '24 ولاية' : '24 Gouvernorats',
              subtitle: isAr ? 'تغطية شاملة' : '100% Tunisie',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseIllustration(bool isAr, double floatOffset) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -floatOffset * 0.6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.goldHero,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.headphones_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr
                                  ? 'سماعات لاسلكية احترافية Pro'
                                  : 'Casque Sans Fil Pro ANC',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isAr
                                  ? 'متجر قرطاج للإلكترونيات'
                                  : 'Carthage Électronique',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            SizedBox(width: 3),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text(
                            '185',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? 'د.ت' : 'TND',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppGradients.emeraldAction,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: AppShadows.emeraldGlow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.call_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAr ? 'اتصل بالتاجر' : 'Appeler',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
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
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniFeatureTile(
                  icon: Icons.verified_user_rounded,
                  color: const Color(0xFF0D9488),
                  label: isAr ? 'متوفر حالياً' : 'Disponibilité',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniFeatureTile(
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFEF4444),
                  label: isAr ? 'قائمة المفضلة' : 'Favoris rapides',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsIllustration(bool isAr, double floatOffset) {
    final bars = [
      (label: isAr ? 'تونس' : 'Tunis', pct: 0.85, count: '1,420'),
      (label: isAr ? 'سوسة' : 'Sousse', pct: 0.62, count: '940'),
      (label: isAr ? 'صفاقس' : 'Sfax', pct: 0.48, count: '710'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -floatOffset * 0.5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppGradients.goldHero,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppShadows.goldGlow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'إجمالي زوار المتجر' : 'Total des Visiteurs',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '3,070+',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      '+24%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...bars.map((b) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        b.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        b.count,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: b.pct,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
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

enum _IllustrationKind { radar, showcase, analytics }

class _SlideSpec {
  final String tag;
  final String title;
  final String subtitle;
  final Color accentColor;
  final _IllustrationKind kind;

  const _SlideSpec({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.kind,
  });
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FloatingBadge({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniFeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MiniFeatureTile({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
