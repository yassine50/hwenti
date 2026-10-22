import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/cache/app_cache_service.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  final bool isAr;

  const SplashScreen({
    super.key,
    required this.onFinished,
    required this.isAr,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    );
    _startSplashAndWarmCache();
  }

  Future<void> _startSplashAndWarmCache() async {
    final Future<void> animFuture = _controller.forward().then((_) {});

    // Warm up L1 + L2 cache & prefetch initial marketplace data in parallel
    final Future<void> cacheWarmupFuture = () async {
      try {
        await AppCacheService.instance.init();
        await Future.wait<void>([
          ApiClient.instance
              .getGovernorates()
              .then((_) {})
              .catchError((_) {}),
          ApiClient.instance
              .getProducts(available: true, limit: 50)
              .then((_) {})
              .catchError((_) {}),
        ]).timeout(const Duration(milliseconds: 1400));
      } catch (_) {}
    }();

    await Future.wait<void>([animFuture, cacheWarmupFuture]);
    if (mounted) {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;

          // 0.0 -> 0.45: Emblem springs in
          final logoScale = Curves.easeOutBack.transform(
            (t / 0.45).clamp(0.0, 1.0),
          );
          // 0.18 -> 0.62: Title & subtitle glide up
          final textProgress = Curves.easeOutCubic.transform(
            ((t - 0.18) / 0.44).clamp(0.0, 1.0),
          );
          // 0.30 -> 0.92: Progress bar fills smoothly
          final barProgress = Curves.easeInOutCubic.transform(
            ((t - 0.25) / 0.70).clamp(0.0, 1.0),
          );

          return DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CustomPaint(
              painter: _SplashOrbitPainter(progress: t),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // Animated 3D Storefront Emblem
                        Transform.scale(
                          scale: logoScale.clamp(0.0, 1.25),
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: AppGradients.goldHero,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.32),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.55),
                                  blurRadius: 36,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Name & Bilingual Tagline
                        Opacity(
                          opacity: textProgress,
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - textProgress) * 18),
                            child: Column(
                              children: [
                                const Text(
                                  'حوانتي',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'HWENTI MARKETPLACE',
                                  style: TextStyle(
                                    color: const Color(0xFFA5B4FC)
                                        .withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.16),
                                    ),
                                  ),
                                  child: Text(
                                    widget.isAr
                                        ? 'السوق المحلي التونسي · 24 ولاية'
                                        : 'Marché Local Tunisien · 24 Gouvernorats',
                                    style: const TextStyle(
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Smooth Loading Progress Indicator at Bottom
                        Opacity(
                          opacity: textProgress,
                          child: Column(
                            children: [
                              Container(
                                width: 160,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                alignment: AlignmentDirectional.centerStart,
                                child: FractionallySizedBox(
                                  widthFactor: barProgress.clamp(0.05, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF10B981),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.isAr
                                    ? 'جاري تجهيز المتاجر والعروض...'
                                    : 'Chargement des offres locales...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SplashOrbitPainter extends CustomPainter {
  final double progress;

  _SplashOrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 36);

    // Expanding radar rings
    for (int i = 0; i < 3; i++) {
      final wavePhase = ((progress * 1.5) - i * 0.22).clamp(0.0, 1.0);
      if (wavePhase <= 0.0 || wavePhase >= 1.0) continue;
      final radius = 48.0 + wavePhase * 165.0;
      final alpha = (1.0 - wavePhase) * 0.25;
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF818CF8).withValues(alpha: alpha);
      canvas.drawCircle(center, radius, ringPaint);
    }

    // Orbiting luminous spark dots
    const dotCount = 8;
    final orbitProgress = Curves.easeOutCubic.transform(
      (progress / 0.80).clamp(0.0, 1.0),
    );
    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi / dotCount) + progress * math.pi * 1.3;
      final dist = 68.0 + orbitProgress * (i.isEven ? 45.0 : 72.0);
      final pos = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist,
      );
      final color = i.isEven
          ? const Color(0xFF10B981)
          : (i % 3 == 0 ? const Color(0xFFF59E0B) : const Color(0xFF818CF8));
      final dotPaint = Paint()
        ..color =
            color.withValues(alpha: (1.0 - progress * 0.35).clamp(0.0, 1.0));
      canvas.drawCircle(pos, i.isEven ? 4.2 : 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashOrbitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
