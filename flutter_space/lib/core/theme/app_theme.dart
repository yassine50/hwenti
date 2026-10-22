import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryAmber = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color action = Color(0xFF0D9488);
  static const Color obsidian = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color surfaceGlass = Color(0xEBFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderHighlight = Color(0xFFC7D2FE);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnLight = Color(0xFFFFFFFF);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

class AppGradients {
  AppGradients._();

  static const LinearGradient goldHero = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tiffanyGlow = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldAction = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassSurface = LinearGradient(
    colors: [Color(0xFAFFFFFF), Color(0xE6FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCard = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x060F172A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x384F46E5),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> tiffanyGlow = [
    BoxShadow(
      color: Color(0x300EA5E9),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> emeraldGlow = [
    BoxShadow(
      color: Color(0x300D9488),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
}

class TradeTypes {
  TradeTypes._();

  static const List<String> all = [
    'clothing',
    'food',
    'electronics',
    'furniture',
    'jewelry',
    'household',
    'toys',
    'other',
  ];

  static const Map<String, Map<String, String>> _labels = {
    'clothing': {'ar': 'ملابس', 'fr': 'Vêtements'},
    'food': {'ar': 'مواد غذائية', 'fr': 'Alimentation'},
    'electronics': {'ar': 'إلكترونيات', 'fr': 'Électronique'},
    'furniture': {'ar': 'أثاث', 'fr': 'Meubles'},
    'jewelry': {'ar': 'مجوهرات', 'fr': 'Bijoux'},
    'household': {'ar': 'أدوات منزلية', 'fr': 'Articles ménagers'},
    'toys': {'ar': 'ألعاب', 'fr': 'Jouets'},
    'other': {'ar': 'أخرى', 'fr': 'Autres'},
  };

  static String label(String? tradeType, String locale) {
    if (tradeType == null || tradeType.isEmpty) return '';
    final map = _labels[tradeType];
    if (map == null) return tradeType;
    return map[locale] ?? map['ar'] ?? tradeType;
  }

  static IconData icon(String? tradeType) {
    switch (tradeType) {
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'food':
        return Icons.restaurant_menu_rounded;
      case 'electronics':
        return Icons.devices_other_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      case 'jewelry':
        return Icons.diamond_rounded;
      case 'household':
        return Icons.kitchen_rounded;
      case 'toys':
        return Icons.toys_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final bool enableHaptic;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.enableHaptic = true,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  void _handleTapCancel() {
    if (_pressed) {
      setState(() => _pressed = false);
    }
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap != null ? _handleTap : null,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

class FadeSlideEntry extends StatelessWidget {
  final Widget child;
  final int index;
  final double verticalOffset;
  final Duration duration;

  const FadeSlideEntry({
    super.key,
    required this.child,
    this.index = 0,
    this.verticalOffset = 18.0,
    this.duration = const Duration(milliseconds: 380),
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: index.clamp(0, 6) * 55);
    return child
        .animate(delay: delay)
        .fadeIn(
          duration: duration,
          curve: Curves.easeOutCubic,
        )
        .moveY(
          begin: verticalOffset,
          end: 0,
          duration: duration,
          curve: Curves.easeOutQuint,
        )
        .scaleXY(
          begin: 0.96,
          end: 1.0,
          duration: duration,
          curve: Curves.easeOutBack,
        );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blur;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppRadius.lg,
    this.borderColor,
    this.backgroundColor,
    this.blur = 18.0,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
        border: Border.all(
          color: borderColor ?? AppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}

class AmbientGlowBackground extends StatelessWidget {
  final Widget child;

  const AmbientGlowBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _StaticAuroraPainter(),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _StaticAuroraPainter extends CustomPainter {
  const _StaticAuroraPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c1 = Offset(size.width * 0.88, size.height * 0.08);
    final r1 = size.width * 0.55;
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4F46E5).withValues(alpha: 0.10),
          const Color(0x004F46E5),
        ],
      ).createShader(Rect.fromCircle(center: c1, radius: r1));
    canvas.drawCircle(c1, r1, p1);

    final c2 = Offset(size.width * 0.12, size.height * 0.48);
    final r2 = size.width * 0.50;
    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0D9488).withValues(alpha: 0.08),
          const Color(0x000D9488),
        ],
      ).createShader(Rect.fromCircle(center: c2, radius: r2));
    canvas.drawCircle(c2, r2, p2);
  }

  @override
  bool shouldRepaint(covariant _StaticAuroraPainter oldDelegate) => false;
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'IBMPlexSansArabic';

  static ThemeData buildTheme(String locale) {
    final baseLight = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
    );
    final textTheme = baseLight.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return baseLight.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnLight,
        onSecondary: AppColors.textOnLight,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnLight,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.obsidian,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textOnLight,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
