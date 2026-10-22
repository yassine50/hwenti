import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedCode = 'ar';

  @override
  void initState() {
    super.initState();
    final current = context.read<LocaleProvider>().locale;
    _selectedCode = (current == 'fr') ? 'fr' : 'ar';
  }

  void _selectLanguage(String code) {
    if (_selectedCode == code) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedCode = code);
    context.read<LocaleProvider>().setLocale(code);
  }

  Future<void> _confirmAndContinue() async {
    HapticFeedback.mediumImpact();
    await context.read<LocaleProvider>().confirmLanguageSelection(_selectedCode);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = _selectedCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AmbientGlowBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),

                  // Top Brand Emblem + Bilingual Welcome Badge
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            gradient: AppGradients.goldHero,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppShadows.goldGlow,
                          ),
                          child: const Icon(
                            Icons.translate_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        )
                            .animate()
                            .scaleXY(
                              begin: 0.6,
                              end: 1.0,
                              duration: 520.ms,
                              curve: Curves.easeOutBack,
                            )
                            .shimmer(
                              delay: 350.ms,
                              duration: 1200.ms,
                              color: Colors.white.withValues(alpha: 0.38),
                            ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.22),
                            ),
                          ),
                          child: const Text(
                            'مرحباً بك في حوانتي · Bienvenue sur Hwenti',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 360.ms)
                            .moveY(begin: 12, end: 0, duration: 360.ms),
                        const SizedBox(height: 16),
                        Text(
                          isAr
                              ? 'اختر لغتك المفضلة'
                              : 'Choisissez votre langue',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        )
                            .animate(delay: 160.ms)
                            .fadeIn(duration: 380.ms)
                            .moveY(begin: 14, end: 0, duration: 380.ms),
                        const SizedBox(height: 8),
                        Text(
                          isAr
                              ? 'يمكنك تغيير اللغة في أي وقت من الإعدادات أو الشريط العلوي'
                              : 'Vous pourrez modifier la langue à tout moment depuis l\'application',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        )
                            .animate(delay: 210.ms)
                            .fadeIn(duration: 380.ms)
                            .moveY(begin: 12, end: 0, duration: 380.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Option 1: Arabic (العربية)
                  _LanguageOptionCard(
                    isSelected: _selectedCode == 'ar',
                    codeBadge: 'ع',
                    title: 'العربية',
                    subtitle: 'تصفح المتاجر والعروض باللغة العربية',
                    regionTag: 'تونس · RTL',
                    accentColor: AppColors.primary,
                    onTap: () => _selectLanguage('ar'),
                  )
                      .animate(delay: 260.ms)
                      .fadeIn(duration: 400.ms)
                      .moveY(
                        begin: 20,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutQuint,
                      )
                      .scaleXY(
                        begin: 0.96,
                        end: 1.0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 14),

                  // Option 2: French (Français)
                  _LanguageOptionCard(
                    isSelected: _selectedCode == 'fr',
                    codeBadge: 'FR',
                    title: 'Français',
                    subtitle: 'Explorer les boutiques et offres en français',
                    regionTag: 'Tunisie · LTR',
                    accentColor: AppColors.primary,
                    onTap: () => _selectLanguage('fr'),
                  )
                      .animate(delay: 340.ms)
                      .fadeIn(duration: 400.ms)
                      .moveY(
                        begin: 20,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutQuint,
                      )
                      .scaleXY(
                        begin: 0.96,
                        end: 1.0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const Spacer(flex: 2),

                  // Primary Continue CTA Button
                  BouncyTap(
                    onTap: _confirmAndContinue,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppGradients.goldHero,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.goldGlow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isAr
                                ? 'متابعة باللغة العربية'
                                : 'Continuer en Français',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            isAr
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    )
                        .animate(delay: 420.ms)
                        .fadeIn(duration: 380.ms)
                        .moveY(begin: 16, end: 0, duration: 380.ms)
                        .shimmer(
                          delay: 750.ms,
                          duration: 1300.ms,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final bool isSelected;
  final String codeBadge;
  final String title;
  final String subtitle;
  final String regionTag;
  final Color accentColor;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.isSelected,
    required this.codeBadge,
    required this.title,
    required this.subtitle,
    required this.regionTag,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppShadows.card,
        ),
        child: Row(
          children: [
            // Language Emblem Circle
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.goldHero : null,
                color: isSelected ? null : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  codeBadge,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected
                              ? accentColor
                              : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.14)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          regionTag,
                          style: TextStyle(
                            color: isSelected
                                ? accentColor
                                : const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Checkmark Radio Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.white,
                border: Border.all(
                  color: isSelected ? accentColor : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
