import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/product/product_detail_screen.dart';

// ============================================================================
// 1. PARTICLE HEART BUTTON (Radial Particle Burst + Elastic Heart Bounce)
// ============================================================================
class ParticleHeartButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const ParticleHeartButton({
    super.key,
    required this.isFavorited,
    required this.onTap,
    this.size = 38,
    this.iconSize = 20,
  });

  @override
  State<ParticleHeartButton> createState() => _ParticleHeartButtonState();
}

class _ParticleHeartButtonState extends State<ParticleHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
  }

  @override
  void didUpdateWidget(covariant ParticleHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFavorited && widget.isFavorited) {
      _burstController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    if (!widget.isFavorited) {
      _burstController.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size + 18,
        height: widget.size + 18,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _burstController,
              builder: (context, _) {
                if (_burstController.value == 0 ||
                    _burstController.value == 1.0) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  size: Size(widget.size + 34, widget.size + 34),
                  painter: _HeartBurstPainter(progress: _burstController.value),
                );
              },
            ),
            AnimatedBuilder(
              animation: _burstController,
              builder: (context, child) {
                double scale = 1.0;
                final t = _burstController.value;
                if (t > 0 && t < 1.0) {
                  scale = 1.0 + math.sin(t * math.pi * 2) * 0.28 * (1.0 - t);
                }
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: widget.isFavorited
                        ? AppColors.error.withValues(alpha: 0.28)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isFavorited
                          ? AppColors.error.withValues(alpha: 0.24)
                          : const Color(0x1F0F172A),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.isFavorited
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: widget.iconSize,
                    color: widget.isFavorited
                        ? AppColors.error
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartBurstPainter extends CustomPainter {
  final double progress;

  _HeartBurstPainter({required this.progress});

  static const List<Color> _palette = [
    Color(0xFFE11D48),
    Color(0xFF4F46E5),
    Color(0xFF059669),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF0D9488),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.54;

    // Expanding shockwave ring
    if (progress < 0.65) {
      final ringProgress = (progress / 0.65).clamp(0.0, 1.0);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - ringProgress) * 3.0
        ..color = const Color(0xFFE11D48)
            .withValues(alpha: (1.0 - ringProgress) * 0.6);
      canvas.drawCircle(center, maxRadius * 0.78 * ringProgress, ringPaint);
    }

    // 12 radial particles
    const count = 12;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count - math.pi / 4;
      final curve = Curves.easeOutCubic.transform(progress);
      final dist = maxRadius * (0.35 + 0.65 * curve);
      final dx = center.dx + math.cos(angle) * dist;
      final dy = center.dy + math.sin(angle) * dist;
      final radius = (1.0 - progress) * (i.isEven ? 3.8 : 2.6);
      final paint = Paint()
        ..color = _palette[i % _palette.length]
            .withValues(alpha: (1.0 - progress).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ============================================================================
// 2. DOUBLE-TAP PHOTO HEART OVERLAY (Instagram-Style 3D Heart + Shockwave)
// ============================================================================
class DoubleTapHeartOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTapFavorite;
  final VoidCallback? onSingleTap;

  const DoubleTapHeartOverlay({
    super.key,
    required this.child,
    required this.onDoubleTapFavorite,
    this.onSingleTap,
  });

  @override
  State<DoubleTapHeartOverlay> createState() => _DoubleTapHeartOverlayState();
}

class _DoubleTapHeartOverlayState extends State<DoubleTapHeartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset? _tapOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _tapOffset = details.localPosition;
  }

  void _onDoubleTap() {
    HapticFeedback.heavyImpact();
    widget.onDoubleTapFavorite();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSingleTap,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              if (t == 0 || t == 1.0) return const SizedBox.shrink();

              final scale = t < 0.35
                  ? Curves.elasticOut.transform((t / 0.35).clamp(0.0, 1.0))
                  : (t < 0.75 ? 1.0 : 1.0 + (t - 0.75) * 1.4);
              final opacity = t < 0.7 ? 1.0 : (1.0 - (t - 0.7) / 0.3);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final pos = _tapOffset ??
                      Offset(
                        constraints.maxWidth / 2,
                        constraints.maxHeight / 2,
                      );
                  return Stack(
                    children: [
                      Positioned(
                        left: pos.dx - 65,
                        top: pos.dy - 65,
                        child: IgnorePointer(
                          child: SizedBox(
                            width: 130,
                            height: 130,
                            child: CustomPaint(
                              painter: _HeartBurstPainter(progress: t),
                              child: Center(
                                child: Opacity(
                                  opacity: opacity.clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF2E63),
                                            Color(0xFFE11D48),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE11D48)
                                                .withValues(alpha: 0.55),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        color: Colors.white,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. PULSE BEACON DOT (Live Breathing Status Indicator with Ripple Ring)
// ============================================================================
class PulseBeaconDot extends StatelessWidget {
  final Color color;
  final double size;

  const PulseBeaconDot({
    super.key,
    required this.color,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.0,
      height: size * 2.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.75,
            height: size * 1.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.22),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. SHIMMER SHEEN WRAPPER (Diagonal Liquid Light Glint on CTAs & Cards)
// ============================================================================
class ShimmerSheenWrapper extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Duration period;

  const ShimmerSheenWrapper({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.period = const Duration(milliseconds: 1400),
  });

  @override
  State<ShimmerSheenWrapper> createState() => _ShimmerSheenWrapperState();
}

class _ShimmerSheenWrapperState extends State<ShimmerSheenWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  if (t >= 0.99 || t == 0.0) return const SizedBox.shrink();
                  final sweep = t * 2.6 - 1.3;
                  return FractionalTranslation(
                    translation: Offset(sweep, 0),
                    child: Transform.rotate(
                      angle: 0.35,
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.26),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. FLOATING LEVITATION & INTERACTIVE 3D TILT CARD
// ============================================================================
class FloatingTilt3DWrapper extends StatefulWidget {
  final Widget child;
  final double floatAmplitude;

  const FloatingTilt3DWrapper({
    super.key,
    required this.child,
    this.floatAmplitude = 6.0,
  });

  @override
  State<FloatingTilt3DWrapper> createState() => _FloatingTilt3DWrapperState();
}

class _FloatingTilt3DWrapperState extends State<FloatingTilt3DWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    final dx = (details.localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (details.localPosition.dy - size.height / 2) / (size.height / 2);
    setState(() {
      _tiltY = (dx.clamp(-1.0, 1.0)) * 0.14;
      _tiltX = -(dy.clamp(-1.0, 1.0)) * 0.14;
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, size),
          onPanEnd: (_) => _resetTilt(),
          onPanCancel: _resetTilt,
          child: AnimatedBuilder(
            animation: _floatCtrl,
            builder: (context, child) {
              final dy = math.sin(_floatCtrl.value * math.pi) *
                  widget.floatAmplitude;
              return TweenAnimationBuilder<Offset>(
                tween: Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset(_tiltX, _tiltY),
                ),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                builder: (context, tilt, _) {
                  final matrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateX(tilt.dx)
                    ..rotateY(tilt.dy);
                  return Transform.translate(
                    offset: Offset(0, -dy),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: matrix,
                      child: child,
                    ),
                  );
                },
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ============================================================================
// 6. ANIMATED ROLLING NUMBER COUNTER
// ============================================================================
class AnimatedRollingCounter extends StatelessWidget {
  final num value;
  final TextStyle style;
  final int fractionDigits;
  final String suffix;
  final Duration duration;

  const AnimatedRollingCounter({
    super.key,
    required this.value,
    required this.style,
    this.fractionDigits = 0,
    this.suffix = '',
    this.duration = const Duration(milliseconds: 950),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (context, animatedVal, _) {
        final formatted = fractionDigits > 0
            ? animatedVal.toStringAsFixed(fractionDigits)
            : animatedVal.round().toString();
        return Text('$formatted$suffix', style: style);
      },
    );
  }
}

// ============================================================================
// 7. CONFETTI CANNON OVERLAY (60-Particle Celebratory Physics Burst)
// ============================================================================
class ConfettiBurstWidget extends StatefulWidget {
  final bool trigger;
  final Widget child;

  const ConfettiBurstWidget({
    super.key,
    required this.trigger,
    required this.child,
  });

  @override
  State<ConfettiBurstWidget> createState() => _ConfettiBurstWidgetState();
}

class _ConfettiBurstWidgetState extends State<ConfettiBurstWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    _pieces = _generatePieces();
    if (widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiBurstWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.trigger && widget.trigger) {
      _pieces = _generatePieces();
      _controller.forward(from: 0);
    }
  }

  List<_ConfettiPiece> _generatePieces() {
    final rng = math.Random(42);
    const colors = [
      Color(0xFF4F46E5),
      Color(0xFF059669),
      Color(0xFFF59E0B),
      Color(0xFFE11D48),
      Color(0xFF0D9488),
      Color(0xFF8B5CF6),
    ];
    return List.generate(48, (i) {
      final angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * 1.8;
      final speed = 160 + rng.nextDouble() * 240;
      return _ConfettiPiece(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        color: colors[i % colors.length],
        size: 6 + rng.nextDouble() * 5,
        spinSpeed: (rng.nextDouble() - 0.5) * 10,
        isCircle: i % 3 == 0,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.value == 0 || _controller.value == 1.0) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _ConfettiPainter(
                    progress: _controller.value,
                    pieces: _pieces,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPiece {
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double spinSpeed;
  final bool isCircle;

  const _ConfettiPiece({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.spinSpeed,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({required this.progress, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.32);
    const gravity = 460.0;
    final t = progress;

    for (final p in pieces) {
      final x = origin.dx + p.vx * t;
      final y = origin.dy + p.vy * t + 0.5 * gravity * t * t;
      final alpha = (1.0 - (t * 0.9)).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spinSpeed * t);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.55, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.6,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ============================================================================
// 8. FLASH STORIES STRIP & FULL-SCREEN INTERACTIVE STORY VIEWER
// ============================================================================
class FlashStoriesStrip extends StatefulWidget {
  final List<ProductModel> products;
  final bool isAr;
  final VoidCallback onOpenRoulette;

  const FlashStoriesStrip({
    super.key,
    required this.products,
    required this.isAr,
    required this.onOpenRoulette,
  });

  @override
  State<FlashStoriesStrip> createState() => _FlashStoriesStripState();
}

class _FlashStoriesStripState extends State<FlashStoriesStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _openStoryViewer(int initialIndex) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InteractiveStoryViewerModal(
        products: widget.products.take(8).toList(),
        initialIndex: initialIndex,
        isAr: widget.isAr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyItems = widget.products.take(8).toList();
    if (storyItems.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 102,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 4,
        ),
        itemCount: storyItems.length + 1,
        itemBuilder: (context, index) {
          // Index 0: Interactive "Surprise Deal Spin / عجلة العروض"
          if (index == 0) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: BouncyTap(
                onTap: widget.onOpenRoulette,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _ringController,
                        builder: (context, child) {
                          return Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                transform: GradientRotation(
                                  _ringController.value * 2 * math.pi,
                                ),
                                colors: const [
                                  Color(0xFF4F46E5),
                                  Color(0xFFEC4899),
                                  Color(0xFFF59E0B),
                                  Color(0xFF059669),
                                  Color(0xFF4F46E5),
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x284F46E5),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.casino_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.isAr ? 'عجلة العروض' : 'Surprise !',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final product = storyItems[index - 1];
          final imageUrl = product.primaryImageUrl;
          final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: BouncyTap(
              onTap: () => _openStoryViewer(index - 1),
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _ringController,
                          builder: (context, child) {
                            return Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(2.6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  transform: GradientRotation(
                                    (_ringController.value + index * 0.15) *
                                        2 *
                                        math.pi,
                                  ),
                                  colors: const [
                                    Color(0xFF4F46E5),
                                    Color(0xFF0D9488),
                                    Color(0xFF6366F1),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: hasImage
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFEEF2FF),
                                        child: const Icon(
                                          Icons.local_offer_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFFEEF2FF),
                                      child: const Icon(
                                        Icons.local_offer_rounded,
                                        color: AppColors.primary,
                                        size: 22,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.action,
                              borderRadius: BorderRadius.circular(99),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              '${product.price.toStringAsFixed(0)} ${widget.isAr ? 'د.ت' : 'DT'}',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InteractiveStoryViewerModal extends StatefulWidget {
  final List<ProductModel> products;
  final int initialIndex;
  final bool isAr;

  const _InteractiveStoryViewerModal({
    required this.products,
    required this.initialIndex,
    required this.isAr,
  });

  @override
  State<_InteractiveStoryViewerModal> createState() =>
      _InteractiveStoryViewerModalState();
}

class _InteractiveStoryViewerModalState
    extends State<_InteractiveStoryViewerModal>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  late int _currentIndex;
  final List<_FloatingReaction> _reactions = [];
  Timer? _reactionCleanupTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _progressController.forward();
  }

  @override
  void dispose() {
    _reactionCleanupTimer?.cancel();
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStory() {
    if (_currentIndex < widget.products.length - 1) {
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      _progressController.forward(from: 0);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      _progressController.forward(from: 0);
    } else {
      _progressController.forward(from: 0);
    }
  }

  void _spawnReaction(String emoji) {
    HapticFeedback.lightImpact();
    final rng = math.Random();
    setState(() {
      for (int i = 0; i < 3; i++) {
        _reactions.add(
          _FloatingReaction(
            id: DateTime.now().microsecondsSinceEpoch + i,
            emoji: emoji,
            startX: 40.0 + rng.nextDouble() * 240.0,
          ),
        );
      }
    });
    _reactionCleanupTimer?.cancel();
    _reactionCleanupTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _reactions.length > 18) {
        setState(() => _reactions.removeRange(0, _reactions.length - 9));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final currentProduct = widget.products[_currentIndex];

    return Container(
      height: screenH * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Story Pages
          PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            onPageChanged: (idx) {
              setState(() => _currentIndex = idx);
              _progressController.forward(from: 0);
            },
            itemBuilder: (context, idx) {
              final item = widget.products[idx];
              final img = item.primaryImageUrl;
              final hasImg = img != null && img.trim().isNotEmpty;
              return GestureDetector(
                onLongPressStart: (_) => _progressController.stop(),
                onLongPressEnd: (_) => _progressController.forward(),
                onTapUp: (details) {
                  final w = MediaQuery.of(context).size.width;
                  if (details.localPosition.dx < w * 0.35) {
                    _prevStory();
                  } else {
                    _nextStory();
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImg)
                      Image.network(img, fit: BoxFit.cover)
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.goldHero,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          size: 96,
                          color: Colors.white38,
                        ),
                      ),
                    // Cinematic dark gradient vignette
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.88),
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Floating Emoji Reactions Stream
          ..._reactions.map(
            (r) => _FloatingEmojiWidget(
              key: ValueKey<int>(r.id),
              emoji: r.emoji,
              startX: r.startX,
            ),
          ),

          // Top Progress Bars + Merchant Info + Close Button
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Animated Segmented Progress Bars
                Row(
                  children: List.generate(widget.products.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: SizedBox(
                            height: 3.5,
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, _) {
                                final val = i < _currentIndex
                                    ? 1.0
                                    : (i == _currentIndex
                                        ? _progressController.value
                                        : 0.0);
                                return LinearProgressIndicator(
                                  value: val,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.28),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.goldHero,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentProduct.merchant.shopName ??
                                (widget.isAr ? 'متجر موثوق' : 'Boutique'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          Row(
                            children: [
                              const PulseBeaconDot(
                                color: Color(0xFF10B981),
                                size: 6,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.isAr
                                    ? 'عرض حصري متوفر الآن'
                                    : 'Offre Flash en direct',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Product Info + Emoji Reactions Bar + CTA
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Emoji Reaction Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['🔥', '😍', '💎', '👏', '🚀'].map((emoji) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: BouncyTap(
                        onTap: () => _spawnReaction(emoji),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Glass Product Spotlight Card inside Story
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentProduct.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.action,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  '${currentProduct.price.toStringAsFixed(1)} ${widget.isAr ? 'د.ت' : 'TND'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (currentProduct.description != null &&
                              currentProduct.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              currentProduct.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          BouncyTap(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: currentProduct.id,
                                  ),
                                ),
                              );
                            },
                            child: ShimmerSheenWrapper(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.goldHero,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.isAr
                                          ? 'عرض تفاصيل المنتج'
                                          : 'Voir les détails de l\'offre',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingReaction {
  final int id;
  final String emoji;
  final double startX;

  const _FloatingReaction({
    required this.id,
    required this.emoji,
    required this.startX,
  });
}

class _FloatingEmojiWidget extends StatefulWidget {
  final String emoji;
  final double startX;

  const _FloatingEmojiWidget({
    super.key,
    required this.emoji,
    required this.startX,
  });

  @override
  State<_FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<_FloatingEmojiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        if (t >= 1.0) return const SizedBox.shrink();
        final dy = 220 + t * 340;
        final dx = widget.startX + math.sin(t * math.pi * 3) * 24;
        final opacity = t < 0.7 ? 1.0 : (1.0 - (t - 0.7) / 0.3);
        final scale = t < 0.2 ? (t / 0.2) * 1.25 : 1.1;

        return Positioned(
          left: dx,
          bottom: dy,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale,
                child: Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 9. DEAL ROULETTE MODAL ("🎲 فاجئني بعرض / Surprise Deal Spinner")
// ============================================================================
Future<void> showDealRouletteModal({
  required BuildContext context,
  required List<ProductModel> products,
  required bool isAr,
}) async {
  if (products.isEmpty) return;
  HapticFeedback.mediumImpact();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DealRouletteSheet(products: products, isAr: isAr),
  );
}

class _DealRouletteSheet extends StatefulWidget {
  final List<ProductModel> products;
  final bool isAr;

  const _DealRouletteSheet({
    required this.products,
    required this.isAr,
  });

  @override
  State<_DealRouletteSheet> createState() => _DealRouletteSheetState();
}

class _DealRouletteSheetState extends State<_DealRouletteSheet> {
  int _activeIndex = 0;
  bool _isSpinning = false;
  bool _won = false;
  Timer? _spinTimer;

  @override
  void initState() {
    super.initState();
    _startSpin();
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  void _startSpin() {
    _spinTimer?.cancel();
    setState(() {
      _isSpinning = true;
      _won = false;
    });

    final rng = math.Random();
    const totalTicks = 18;
    int tick = 0;

    void scheduleNext() {
      if (!mounted) return;
      tick++;
      HapticFeedback.selectionClick();
      setState(() {
        _activeIndex = (_activeIndex + 1 + rng.nextInt(2)) %
            widget.products.length;
      });
      if (tick < totalTicks) {
        final delayMs = 55 + (tick * tick * 1.4).round();
        _spinTimer = Timer(Duration(milliseconds: delayMs), scheduleNext);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _isSpinning = false;
          _won = true;
        });
      }
    }

    scheduleNext();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.products[_activeIndex % widget.products.length];
    final imageUrl = current.primaryImageUrl;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return ConfettiBurstWidget(
      trigger: _won,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppGradients.goldHero,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.casino_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isAr
                      ? (_won ? '🎉 عرضك المميز اليوم!' : 'جاري اختيار عرض لك...')
                      : (_won
                          ? '🎉 Votre Offre Surprise !'
                          : 'Sélection d\'une offre...'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Animated 3D Slot Card
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, anim) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                );
              },
              child: Container(
                key: ValueKey<String>(current.id),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _won ? AppColors.primary : AppColors.borderSubtle,
                    width: _won ? 2.2 : 1.0,
                  ),
                  boxShadow: _won ? AppShadows.goldGlow : AppShadows.card,
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: hasImage
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: AppGradients.goldHero,
                                ),
                                child: const Icon(
                                  Icons.local_offer_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                current.merchant.shopName ??
                                    (widget.isAr ? 'متجر موثوق' : 'Marchand'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppGradients.emeraldAction,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${current.price.toStringAsFixed(1)} ${widget.isAr ? 'د.ت' : 'TND'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: BouncyTap(
                    onTap: _isSpinning ? null : _startSpin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.isAr ? 'لف مرة أخرى' : 'Relancer',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BouncyTap(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(productId: current.id),
                        ),
                      );
                    },
                    child: ShimmerSheenWrapper(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppGradients.goldHero,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.goldGlow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.isAr
                                  ? 'تصفح هذا العرض'
                                  : 'Voir cette offre',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 10. COMPACT 2-COLUMN BENTO GRID PRODUCT CARD (For Grid/Feed Toggle)
// ============================================================================
class BentoGridProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isAr;

  const BentoGridProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onToggleFavorite,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.primaryImageUrl;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return BouncyTap(
      scaleDown: 0.96,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DoubleTapHeartOverlay(
                    onSingleTap: onTap,
                    onDoubleTapFavorite: onToggleFavorite,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasImage)
                          Image.network(imageUrl, fit: BoxFit.cover)
                        else
                          Container(
                            color: const Color(0xFFEEF2FF),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.primary,
                              size: 34,
                            ),
                          ),
                        PositionedDirectional(
                          top: 4,
                          end: 4,
                          child: ParticleHeartButton(
                            isFavorited: product.isFavorited,
                            onTap: onToggleFavorite,
                            size: 32,
                            iconSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${product.price.toStringAsFixed(1)} ${isAr ? 'د.ت' : 'DT'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.action,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.merchant.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
