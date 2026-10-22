import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/filter_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';

class FilterTab extends StatefulWidget {
  const FilterTab({super.key});

  @override
  State<FilterTab> createState() => _FilterTabState();
}

class _FilterTabState extends State<FilterTab> {
  List<GovernorateModel> _governorates = [];
  List<DelegationModel> _delegations = [];
  List<MerchantModel> _merchants = [];

  bool _loadingGovs = false;
  bool _loadingDels = false;
  bool _loadingMerchants = false;

  String? _loadedGovIdForDelegations;
  String? _lastMerchantFilterKey;
  FilterProvider? _filterRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGovernorates();
      _syncWithFilterProvider();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final filter = context.read<FilterProvider>();
    if (_filterRef != filter) {
      _filterRef?.removeListener(_syncWithFilterProvider);
      _filterRef = filter;
      _filterRef!.addListener(_syncWithFilterProvider);
    }
  }

  @override
  void dispose() {
    _filterRef?.removeListener(_syncWithFilterProvider);
    super.dispose();
  }

  void _syncWithFilterProvider() {
    if (!mounted || _filterRef == null) return;
    final filter = _filterRef!;

    if (filter.focusedSection != null) {
      final section = filter.focusedSection;
      filter.clearFocusedSection();
      if (section == 'governorate' && _governorates.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openGovernorateSheet();
        });
      } else if (section == 'merchant' && _merchants.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openMerchantSheet();
        });
      }
    }

    if (filter.governorateId != _loadedGovIdForDelegations) {
      _loadedGovIdForDelegations = filter.governorateId;
      if (filter.governorateId != null && filter.governorateId!.isNotEmpty) {
        _loadDelegations(filter.governorateId!);
      } else {
        setState(() {
          _delegations = [];
        });
      }
    }

    final merchantKey =
        '${filter.governorateId ?? ''}|${filter.delegationId ?? ''}|${filter.tradeType ?? ''}';
    if (merchantKey != _lastMerchantFilterKey) {
      _lastMerchantFilterKey = merchantKey;
      _loadMerchants();
    }
  }

  Future<void> _loadGovernorates() async {
    final cached = ApiClient.instance.getCachedGovernoratesSync();
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _governorates = cached;
        _loadingGovs = false;
      });
    } else {
      setState(() => _loadingGovs = true);
    }
    try {
      final list = await ApiClient.instance.getGovernorates();
      if (!mounted) return;
      setState(() {
        _governorates = list;
        _loadingGovs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingGovs = false);
    }
  }

  Future<void> _loadDelegations(String governorateId) async {
    final cached = ApiClient.instance.getCachedDelegationsSync(governorateId);
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _delegations = cached;
        _loadingDels = false;
      });
    } else {
      setState(() => _loadingDels = true);
    }
    try {
      final list = await ApiClient.instance.getDelegations(governorateId);
      if (!mounted) return;
      setState(() {
        _delegations = list;
        _loadingDels = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDels = false);
    }
  }

  Future<void> _loadMerchants() async {
    if (!mounted) return;
    final filter = context.read<FilterProvider>();

    setState(() => _loadingMerchants = true);
    try {
      final res = await ApiClient.instance.getMerchants(
        governorateId: filter.governorateId,
        delegationId: filter.delegationId,
        tradeType: filter.tradeType,
        limit: 50,
      );
      if (!mounted) return;
      setState(() {
        _merchants = res.items;
        _loadingMerchants = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMerchants = false);
    }
  }

  void _clearAllFilters(FilterProvider filter) {
    HapticFeedback.lightImpact();
    filter.clearAll();
    _loadMerchants();
  }

  int _countActiveFilters(FilterProvider filter) {
    int count = 0;
    if (filter.tradeType != null && filter.tradeType!.isNotEmpty) count++;
    if (filter.governorateId != null && filter.governorateId!.isNotEmpty) {
      count++;
    }
    if (filter.delegationId != null && filter.delegationId!.isNotEmpty) count++;
    if (filter.merchantId != null && filter.merchantId!.isNotEmpty) count++;
    return count;
  }

  void _openGovernorateSheet() {
    final locale = context.read<LocaleProvider>();
    final filter = context.read<FilterProvider>();
    final isAr = locale.locale == 'ar';
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = _governorates.where((g) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return g.nameAr.toLowerCase().contains(q) ||
                  g.nameFr.toLowerCase().contains(q) ||
                  g.name.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            locale.t('governorate'),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (filter.governorateId != null)
                          TextButton(
                            onPressed: () {
                              filter.setGovernorate(null, null);
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              locale.t('clear'),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        onChanged: (v) =>
                            setSheetState(() => searchQuery = v.trim()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: isAr
                              ? 'ابحث عن ولاية...'
                              : 'Rechercher un gouvernorat...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13.5,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.9,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        final selected = filter.governorateId == item.id;
                        final name = item.localizedName(locale.locale);

                        return BouncyTap(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (selected) {
                              filter.setGovernorate(null, null);
                            } else {
                              filter.setGovernorate(
                                item.id,
                                name,
                                nameAr: item.nameAr,
                                nameFr: item.nameFr,
                              );
                            }
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFEEF2FF)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFFE2E8F0),
                                width: selected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openMerchantSheet() {
    final locale = context.read<LocaleProvider>();
    final filter = context.read<FilterProvider>();
    final isAr = locale.locale == 'ar';
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = _merchants.where((m) {
              if (searchQuery.isEmpty) return true;
              final q = searchQuery.toLowerCase();
              return (m.shopName ?? '').toLowerCase().contains(q) ||
                  m.localizedGov(locale.locale).toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            locale.t('theMerchant'),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (filter.merchantId != null)
                          TextButton(
                            onPressed: () {
                              filter.setMerchant(null, null);
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              locale.t('clear'),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        onChanged: (v) =>
                            setSheetState(() => searchQuery = v.trim()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: isAr
                              ? 'ابحث عن متجر...'
                              : 'Rechercher un marchand...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13.5,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              locale.t('noData'),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final m = filtered[i];
                              final selected = filter.merchantId == m.id;
                              final shopName =
                                  m.shopName ?? locale.t('merchant');
                              final hasLogo = m.logoUrl != null &&
                                  m.logoUrl!.trim().isNotEmpty;

                              return BouncyTap(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  if (selected) {
                                    filter.setMerchant(null, null);
                                  } else {
                                    filter.setMerchant(m.id, shopName);
                                  }
                                  Navigator.of(ctx).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFEEF2FF)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : const Color(0xFFE2E8F0),
                                      width: selected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            const Color(0xFFE2E8F0),
                                        backgroundImage: hasLogo
                                            ? NetworkImage(m.logoUrl!)
                                            : null,
                                        child: !hasLogo
                                            ? const Icon(
                                                Icons.storefront_rounded,
                                                color: AppColors.primary,
                                                size: 20,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              shopName,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: selected
                                                    ? AppColors.primary
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: AppColors.primaryAmber,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  m.averageRating
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                if (m
                                                    .localizedGov(locale.locale)
                                                    .isNotEmpty) ...[
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      '· ${m.localizedGov(locale.locale)}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (actionText != null && onAction != null)
            BouncyTap(
              onTap: onAction,
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final filter = context.watch<FilterProvider>();
    final isAr = locale.locale == 'ar';
    final activeCount = _countActiveFilters(filter);
    final quickGovs = _governorates.take(8).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          HwentiHeader(
            title: locale.t('filter'),
            trailing: activeCount > 0
                ? BouncyTap(
                    onTap: () => _clearAllFilters(filter),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(
                          locale.t('clear'),
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),

          // Main Single-Scroll Filter Content (Zero Nested Scroll Traps!)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                // ──────────────────────────────────────────────────────────
                // 1. CATEGORY GRID (1-Tap Visual Selection)
                // ──────────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        icon: Icons.category_rounded,
                        title: locale.t('tradeType'),
                        actionText: filter.tradeType != null
                            ? locale.t('clear')
                            : null,
                        onAction: filter.tradeType != null
                            ? () => filter.setTradeType(null)
                            : null,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CategoryTileChip(
                            label: isAr ? 'الكل' : 'Tout',
                            icon: Icons.grid_view_rounded,
                            selected: filter.tradeType == null ||
                                filter.tradeType!.isEmpty,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              filter.setTradeType(null);
                            },
                          ),
                          ...TradeTypes.all.map((tt) {
                            final selected = filter.tradeType == tt;
                            return _CategoryTileChip(
                              label: TradeTypes.label(tt, locale.locale),
                              icon: TradeTypes.icon(tt),
                              selected: selected,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                filter.setTradeType(selected ? null : tt);
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ──────────────────────────────────────────────────────────
                // 2. LOCATION CARD (Governorate + Progressive Delegation)
                // ──────────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        icon: Icons.location_on_rounded,
                        title: locale.t('governorate'),
                        actionText: _governorates.isNotEmpty
                            ? (isAr ? 'عرض الكل (24)' : 'Voir tout (24)')
                            : null,
                        onAction: _openGovernorateSheet,
                      ),

                      // Clean Selector Field (Opens Full Sheet)
                      BouncyTap(
                        onTap: _openGovernorateSheet,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: filter.governorateId != null
                                ? const Color(0xFFEEF2FF)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: filter.governorateId != null
                                  ? AppColors.primary
                                  : const Color(0xFFE2E8F0),
                              width: filter.governorateId != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: filter.governorateId != null
                                    ? AppColors.primary
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  filter.localizedGovernorateName(
                                        locale.locale,
                                      ) ??
                                      (isAr
                                          ? 'اختر الولاية (كل تونس)'
                                          : 'Choisir un gouvernorat (Toute la Tunisie)'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: filter.governorateId != null
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: filter.governorateId != null
                                        ? AppColors.primary
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                              if (filter.governorateId != null)
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    filter.setGovernorate(null, null);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Quick-Tap Popular Governorate Chips
                      if (!_loadingGovs && quickGovs.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...quickGovs.map((g) {
                              final selected = filter.governorateId == g.id;
                              final name = g.localizedName(locale.locale);
                              return BouncyTap(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  if (selected) {
                                    filter.setGovernorate(null, null);
                                  } else {
                                    filter.setGovernorate(
                                      g.id,
                                      name,
                                      nameAr: g.nameAr,
                                      nameFr: g.nameFr,
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            BouncyTap(
                              onTap: _openGovernorateSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  isAr ? '+ المزيد...' : '+ Plus...',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Progressive Disclosure: Delegations appear ONLY when a Governorate is selected
                      if (filter.governorateId != null &&
                          filter.governorateId!.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        _buildSectionTitle(
                          icon: Icons.place_rounded,
                          title: locale.t('delegation'),
                          actionText: filter.delegationId != null
                              ? locale.t('clear')
                              : null,
                          onAction: filter.delegationId != null
                              ? () => filter.setDelegation(null, null)
                              : null,
                        ),
                        if (_loadingDels)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        else if (_delegations.isEmpty)
                          Text(
                            locale.t('noData'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              BouncyTap(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  filter.setDelegation(null, null);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: filter.delegationId == null
                                        ? AppColors.primary
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Text(
                                    isAr ? 'الكل' : 'Toutes',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: filter.delegationId == null
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                              ..._delegations.map((d) {
                                final selected = filter.delegationId == d.id;
                                final name = d.localizedName(locale.locale);
                                return BouncyTap(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    if (selected) {
                                      filter.setDelegation(null, null);
                                    } else {
                                      filter.setDelegation(
                                        d.id,
                                        name,
                                        nameAr: d.nameAr,
                                        nameFr: d.nameFr,
                                      );
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primary
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ──────────────────────────────────────────────────────────
                // 3. MERCHANT SELECTOR CARD
                // ──────────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        icon: Icons.storefront_rounded,
                        title: locale.t('theMerchant'),
                        actionText: _merchants.isNotEmpty
                            ? (isAr ? 'بحث' : 'Choisir')
                            : null,
                        onAction:
                            _merchants.isNotEmpty ? _openMerchantSheet : null,
                      ),
                      BouncyTap(
                        onTap: _openMerchantSheet,
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: filter.merchantId != null
                                ? const Color(0xFFEEF2FF)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: filter.merchantId != null
                                  ? AppColors.primary
                                  : const Color(0xFFE2E8F0),
                              width: filter.merchantId != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.store_mall_directory_rounded,
                                size: 20,
                                color: filter.merchantId != null
                                    ? AppColors.primary
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  filter.merchantName ??
                                      (isAr
                                          ? 'كل المتاجر والتجار'
                                          : 'Tous les marchands'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: filter.merchantId != null
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: filter.merchantId != null
                                        ? AppColors.primary
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                              if (filter.merchantId != null)
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    filter.setMerchant(null, null);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF64748B),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!_loadingMerchants && _merchants.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemCount: _merchants.take(10).length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (ctx, i) {
                              final m = _merchants[i];
                              final selected = filter.merchantId == m.id;
                              final shopName =
                                  m.shopName ?? locale.t('merchant');
                              return BouncyTap(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  if (selected) {
                                    filter.setMerchant(null, null);
                                  } else {
                                    filter.setMerchant(m.id, shopName);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.storefront_rounded,
                                        size: 15,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        shopName,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: selected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Clean Docked Bottom Action Bar (20px grid alignment)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                if (activeCount > 0) ...[
                  BouncyTap(
                    onTap: () => _clearAllFilters(filter),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          locale.t('clear'),
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: BouncyTap(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      filter.setTabIndex(0);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppGradients.goldHero,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.goldGlow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activeCount > 0
                                ? '${locale.t('apply')} ($activeCount)'
                                : locale.t('apply'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTileChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTileChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.goldHero : null,
          color: selected ? null : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE2E8F0),
          ),
          boxShadow: selected ? AppShadows.goldGlow : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
