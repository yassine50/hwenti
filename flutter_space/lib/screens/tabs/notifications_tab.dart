import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/models/models.dart';
import 'package:hwenti_flutter/core/providers/filter_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/merchant/merchant_profile_screen.dart';
import 'package:hwenti_flutter/screens/product/product_detail_screen.dart';
import 'package:hwenti_flutter/widgets/hwenti_header.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  String _segment = 'notifs'; // 'notifs' | 'follows'
  List<NotificationItemModel> _notifications = [];
  List<FollowItemModel> _follows = [];
  bool _loadingNotifs = true;
  bool _loadingFollows = true;

  int _lastTabIndex = 0;
  FilterProvider? _filterRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications(showSpinner: true);
      _loadFollows(showSpinner: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final filter = context.read<FilterProvider>();
    if (_filterRef != filter) {
      _filterRef?.removeListener(_onTabChanged);
      _filterRef = filter;
      _lastTabIndex = filter.currentTabIndex;
      _filterRef!.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    _filterRef?.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted || _filterRef == null) return;
    final current = _filterRef!.currentTabIndex;
    if (current == 3 && _lastTabIndex != 3) {
      _loadNotifications(showSpinner: false);
      _loadFollows(showSpinner: false);
    }
    _lastTabIndex = current;
  }

  Future<void> _loadNotifications({bool showSpinner = false}) async {
    if (!mounted) return;
    if (showSpinner) {
      setState(() => _loadingNotifs = true);
    }
    try {
      final res = await ApiClient.instance.getNotifications(limit: 50);
      if (!mounted) return;
      setState(() {
        _notifications = res.items;
        _loadingNotifs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingNotifs = false);
    }
  }

  Future<void> _loadFollows({bool showSpinner = false}) async {
    if (!mounted) return;
    if (showSpinner) {
      setState(() => _loadingFollows = true);
    }
    try {
      final res = await ApiClient.instance.getFollows(limit: 50);
      if (!mounted) return;
      setState(() {
        _follows = res.items;
        _loadingFollows = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFollows = false);
    }
  }

  String _formatDate(String raw, String localeCode) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    try {
      return DateFormat('yyyy/MM/dd HH:mm', localeCode == 'ar' ? 'ar' : 'fr')
          .format(dt.toLocal());
    } catch (_) {
      final l = dt.toLocal();
      return '${l.year}/${l.month.toString().padLeft(2, '0')}/${l.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _onTapNotification(NotificationItemModel item) async {
    if (!item.isRead) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.id == item.id ? n.copyWith(isRead: true) : n)
            .toList();
      });
      try {
        await ApiClient.instance.markNotificationRead(item.id);
      } catch (_) {}
    }

    if (!mounted) return;
    if (item.productId != null && item.productId!.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: item.productId!),
        ),
      );
    } else if (item.merchantId.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MerchantProfileScreen(merchantId: item.merchantId),
        ),
      );
    }
  }

  Future<void> _unfollowMerchant(String merchantId) async {
    final previous = List<FollowItemModel>.from(_follows);
    setState(() {
      _follows.removeWhere((f) => f.merchant.id == merchantId);
    });
    try {
      await ApiClient.instance.unfollowMerchant(merchantId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _follows = previous;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isNotifs = _segment == 'notifs';
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientGlowBackground(
        child: Column(
          children: [
            HwentiHeader(title: locale.t('notifications')),

            // Slate #F1F5F9 Segmented Control with Sliding White/Indigo Pill
            Container(
              margin: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                6,
              ),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BouncyTap(
                      onTap: () => setState(() => _segment = 'notifs'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: isNotifs ? AppGradients.goldHero : null,
                          color: isNotifs ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: isNotifs ? AppShadows.goldGlow : const [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_rounded,
                              size: 17,
                              color: isNotifs
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              locale.t('notifications'),
                              style: TextStyle(
                                color: isNotifs
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isNotifs
                                      ? Colors.white
                                      : AppColors.error,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: TextStyle(
                                    color: isNotifs
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: BouncyTap(
                      onTap: () => setState(() => _segment = 'follows'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: !isNotifs ? AppGradients.goldHero : null,
                          color: !isNotifs ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow:
                              !isNotifs ? AppShadows.goldGlow : const [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              size: 17,
                              color: !isNotifs
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              locale.t('follows'),
                              style: TextStyle(
                                color: !isNotifs
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_follows.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: !isNotifs
                                      ? Colors.white
                                      : AppColors.primary,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                                child: Text(
                                  '${_follows.length}',
                                  style: TextStyle(
                                    color: !isNotifs
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isNotifs
                  ? _buildNotificationsList(locale)
                  : _buildFollowsList(locale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(LocaleProvider locale) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => _loadNotifications(showSpinner: false),
      child: _loadingNotifs
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _notifications.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    const SizedBox(height: 50),
                    GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      borderRadius: AppRadius.xl,
                      backgroundColor: AppColors.surface,
                      borderColor: AppColors.borderSubtle,
                      shadows: AppShadows.card,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_off_outlined,
                              size: 46,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            locale.t('noNotifications'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: 110,
                  ),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final hasLogo = item.merchantLogoUrl != null &&
                        item.merchantLogoUrl!.trim().isNotEmpty;
                    final unread = !item.isRead;
                    return FadeSlideEntry(
                      index: index,
                      child: BouncyTap(
                        onTap: () => _onTapNotification(item),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: unread
                                ? const Color(0xFFEEF2FF)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: unread
                                  ? AppColors.primary
                                  : AppColors.borderSubtle,
                              width: unread ? 1.5 : 1.0,
                            ),
                            boxShadow: AppShadows.card,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: unread
                                      ? AppGradients.goldHero
                                      : null,
                                  color: unread
                                      ? null
                                      : AppColors.borderSubtle,
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.surfaceElevated,
                                  backgroundImage: hasLogo
                                      ? NetworkImage(item.merchantLogoUrl!)
                                      : null,
                                  child: !hasLogo
                                      ? const Icon(
                                          Icons.notifications_active_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.merchantName != null &&
                                        item.merchantName!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 3,
                                        ),
                                        child: Text(
                                          item.merchantName!,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: unread
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs + 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule_rounded,
                                          size: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(
                                            item.createdAt,
                                            locale.locale,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (unread)
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
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

  Widget _buildFollowsList(LocaleProvider locale) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => _loadFollows(showSpinner: false),
      child: _loadingFollows
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _follows.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    const SizedBox(height: 50),
                    GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      borderRadius: AppRadius.xl,
                      backgroundColor: AppColors.surface,
                      borderColor: AppColors.borderSubtle,
                      shadows: AppShadows.card,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people_outline_rounded,
                              size: 46,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            locale.t('noFollows'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: 110,
                  ),
                  itemCount: _follows.length,
                  itemBuilder: (context, index) {
                    final item = _follows[index];
                    final m = item.merchant;
                    final hasLogo =
                        m.logoUrl != null && m.logoUrl!.trim().isNotEmpty;
                    final shopName =
                        (m.shopName != null && m.shopName!.isNotEmpty)
                            ? m.shopName!
                            : locale.t('theMerchant');
                    final tradeLabel = TradeTypes.label(
                      m.tradeType,
                      locale.locale,
                    );
                    final govName = m.localizedGov(locale.locale);

                    return FadeSlideEntry(
                      index: index,
                      child: GlassContainer(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppRadius.lg,
                        backgroundColor: AppColors.surface,
                        borderColor: AppColors.borderSubtle,
                        shadows: AppShadows.card,
                        child: Row(
                          children: [
                            Expanded(
                              child: BouncyTap(
                                onTap: m.id.isNotEmpty
                                    ? () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                MerchantProfileScreen(
                                              merchantId: m.id,
                                            ),
                                          ),
                                        );
                                        if (mounted) {
                                          _loadFollows(showSpinner: false);
                                        }
                                      }
                                    : null,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppGradients.goldHero,
                                      ),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            AppColors.surfaceElevated,
                                        backgroundImage: hasLogo
                                            ? NetworkImage(m.logoUrl!)
                                            : null,
                                        child: !hasLogo
                                            ? Icon(
                                                TradeTypes.icon(m.tradeType),
                                                color: AppColors.primary,
                                                size: 22,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            shopName,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Wrap(
                                            spacing: AppSpacing.xs + 2,
                                            runSpacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              if (tradeLabel.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: AppSpacing.sm,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFEEF2FF,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      AppRadius.full,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        TradeTypes.icon(
                                                          m.tradeType,
                                                        ),
                                                        size: 12,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        tradeLabel,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (govName.isNotEmpty)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.place_rounded,
                                                      size: 13,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      govName,
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontSize: 12,
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
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            BouncyTap(
                              onTap: () => _unfollowMerchant(m.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm + 4,
                                  vertical: AppSpacing.xs + 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  locale.t('unfollow'),
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
