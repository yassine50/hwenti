import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  VisitorStatsSummary? _summary;
  String? _selectedGovernorateId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await ApiClient.instance.getVisitorStatsSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleGovernorate(String governorateId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedGovernorateId == governorateId) {
        _selectedGovernorateId = null;
      } else {
        _selectedGovernorateId = governorateId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isAr = locale.locale == 'ar';
    final summary = _summary;

    final sortedGovs = [...(summary?.byGovernorate ?? const <GovStatModel>[])]
      ..sort((a, b) => b.count.compareTo(a.count));

    final maxGovCount = sortedGovs.isEmpty
        ? 1
        : sortedGovs.map((g) => g.count).reduce(math.max).clamp(1, 1 << 30);

    final allDels = [...(summary?.byDelegation ?? const <DelStatModel>[])]
      ..sort((a, b) => b.count.compareTo(a.count));

    final filteredDels = _selectedGovernorateId == null
        ? allDels
        : allDels
            .where((d) => d.governorateId == _selectedGovernorateId)
            .toList();

    final maxDelCount = filteredDels.isEmpty
        ? 1
        : filteredDels.map((d) => d.count).reduce(math.max).clamp(1, 1 << 30);

    GovStatModel? selectedGovModel;
    if (_selectedGovernorateId != null) {
      for (final g in sortedGovs) {
        if (g.governorateId == _selectedGovernorateId) {
          selectedGovModel = g;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            HwentiHeader(
              title: locale.t('stats'),
              showBack: true,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _error != null
                      ? _buildErrorState(locale)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          onRefresh: _loadStats,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FadeSlideEntry(
                                  index: 0,
                                  child: _buildHeroTotalVisitorsCard(
                                    summary?.totalVisitors ?? 0,
                                    sortedGovs,
                                    locale,
                                    isAr,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                FadeSlideEntry(
                                  index: 1,
                                  child: _buildGovernoratesBento(
                                    sortedGovs,
                                    maxGovCount,
                                    summary?.totalVisitors ?? 0,
                                    locale,
                                    isAr,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                FadeSlideEntry(
                                  index: 2,
                                  child: _buildDelegationsBento(
                                    filteredDels,
                                    maxDelCount,
                                    selectedGovModel,
                                    locale,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(LocaleProvider locale) {
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
              const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error ?? locale.t('error'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BouncyTap(
                onTap: _loadStats,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.goldHero,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    locale.t('retry'),
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

  Widget _buildHeroTotalVisitorsCard(
    int totalVisitors,
    List<GovStatModel> sortedGovs,
    LocaleProvider locale,
    bool isAr,
  ) {
    final topGovName = sortedGovs.isNotEmpty
        ? sortedGovs.first.localizedName(locale.locale)
        : '-';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.goldHero,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.goldGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  locale.t('totalVisitors'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: totalVisitors.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Text(
                '${val.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isAr
                      ? '${sortedGovs.length} ولاية نشطة'
                      : '${sortedGovs.length} gouvernorats actifs',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (sortedGovs.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '1# $topGovName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGovernoratesBento(
    List<GovStatModel> sortedGovs,
    int maxGovCount,
    int totalVisitors,
    LocaleProvider locale,
    bool isAr,
  ) {
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
              const Icon(
                Icons.map_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locale.t('byGovernorate'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (_selectedGovernorateId != null)
                BouncyTap(
                  onTap: () => setState(() => _selectedGovernorateId = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      locale.t('clear'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'اضغط على أي ولاية لتصفية المعتمديات التابعة لها'
                : 'Touchez un gouvernorat pour filtrer ses délégations',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (sortedGovs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  locale.t('noData'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...List.generate(sortedGovs.length, (index) {
              final gov = sortedGovs[index];
              final isSelected = _selectedGovernorateId == gov.governorateId;
              final ratio = (gov.count / maxGovCount).clamp(0.04, 1.0);
              final sharePct = totalVisitors > 0
                  ? ((gov.count / totalVisitors) * 100).round()
                  : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BouncyTap(
                  onTap: () => _toggleGovernorate(gov.governorateId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                gov.localizedName(locale.locale),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '${gov.count}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($sharePct%)',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: Container(
                            height: 8,
                            width: double.infinity,
                            color: AppColors.surface,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: ratio),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, val, _) {
                                return FractionallySizedBox(
                                  alignment: AlignmentDirectional.centerStart,
                                  widthFactor: val,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? AppGradients.goldHero
                                          : AppGradients.tiffanyGlow,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.full,
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
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDelegationsBento(
    List<DelStatModel> filteredDels,
    int maxDelCount,
    GovStatModel? selectedGov,
    LocaleProvider locale,
  ) {
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
              const Icon(
                Icons.place_outlined,
                color: AppColors.action,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedGov != null
                      ? '${locale.t('byDelegation')} • ${selectedGov.localizedName(locale.locale)}'
                      : locale.t('byDelegation'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (filteredDels.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  locale.t('noData'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...filteredDels.map((del) {
              final ratio = (del.count / maxDelCount).clamp(0.04, 1.0);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            del.localizedName(locale.locale),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        Text(
                          '${del.count}',
                          style: const TextStyle(
                            color: AppColors.action,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Container(
                        height: 6,
                        width: double.infinity,
                        color: AppColors.surface,
                        child: FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: ratio,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppGradients.emeraldAction,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                          ),
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
