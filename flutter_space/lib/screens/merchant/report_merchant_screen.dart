import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';

class ReportMerchantScreen extends StatefulWidget {
  final String merchantId;
  final String? merchantName;

  const ReportMerchantScreen({
    super.key,
    required this.merchantId,
    this.merchantName,
  });

  @override
  State<ReportMerchantScreen> createState() => _ReportMerchantScreenState();
}

class _ReportMerchantScreenState extends State<ReportMerchantScreen> {
  static const List<String> _reasons = [
    'counterfeit',
    'fraud',
    'inappropriate',
    'other',
  ];

  final TextEditingController _detailsController = TextEditingController();
  String _selectedReason = '';
  bool _isSubmitting = false;
  bool _isSent = false;
  String? _error;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  IconData _reasonIcon(String reason) {
    switch (reason) {
      case 'counterfeit':
        return Icons.verified_user_outlined;
      case 'fraud':
        return Icons.gpp_bad_outlined;
      case 'inappropriate':
        return Icons.block_flipped;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Future<void> _handleSubmit() async {
    final locale = context.read<LocaleProvider>();
    if (_selectedReason.isEmpty) {
      setState(() {
        _error = locale.t('selectReason');
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ApiClient.instance.reportMerchant(
        merchantId: widget.merchantId,
        reason: _selectedReason,
        details: _detailsController.text.trim().isNotEmpty
            ? _detailsController.text.trim()
            : null,
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _isSent = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            HwentiHeader(
              title: locale.t('report'),
              showBack: true,
            ),
            Expanded(
              child: _isSent
                  ? _buildSuccessView(locale)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if ((widget.merchantName ?? '').trim().isNotEmpty) ...[
                            FadeSlideEntry(
                              index: 0,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xl),
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                  ),
                                  boxShadow: AppShadows.card,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.error
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.storefront_rounded,
                                        color: AppColors.error,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            locale.t('theMerchant'),
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            widget.merchantName!.trim(),
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          FadeSlideEntry(
                            index: 1,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                                boxShadow: AppShadows.card,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    locale.t('reportReason'),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ..._reasons.map((reason) {
                                    final isSelected =
                                        _selectedReason == reason;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: BouncyTap(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _selectedReason = reason;
                                            _error = null;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 180),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.06)
                                                : AppColors.surfaceElevated,
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.borderSubtle,
                                              width: isSelected ? 1.8 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                          .withValues(
                                                            alpha: 0.14,
                                                          )
                                                      : AppColors.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  _reasonIcon(reason),
                                                  size: 19,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  locale.t(reason),
                                                  style: TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w800
                                                        : FontWeight.w600,
                                                    fontSize: 14.5,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                isSelected
                                                    ? Icons
                                                        .radio_button_checked_rounded
                                                    : Icons
                                                        .radio_button_off_rounded,
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    locale.t('details'),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _detailsController,
                                    maxLines: 4,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          locale.t('additionalDetailsHint'),
                                      hintStyle: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.surfaceElevated,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.borderSubtle,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.borderSubtle,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FadeSlideEntry(
                            index: 2,
                            child: BouncyTap(
                              onTap: _isSubmitting ? null : _handleSubmit,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.goldHero,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  boxShadow: AppShadows.goldGlow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isSubmitting)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 19,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isSubmitting
                                          ? locale.t('loading')
                                          : locale.t('send'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(LocaleProvider locale) {
    final isAr = locale.locale == 'ar';
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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: AppGradients.emeraldAction,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.emeraldGlow,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                locale.t('reportSent'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'شكراً لمساهمتك في الحفاظ على جودة وموثوقية السوق.'
                    : 'Merci de nous aider à maintenir la qualité de la communauté.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              BouncyTap(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.goldHero,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    locale.t('back'),
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
}
