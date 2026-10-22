import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/filter_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/merchant_setup_screen.dart';
import 'package:hwenti_flutter/screens/tabs/favorites_tab.dart';
import 'package:hwenti_flutter/screens/tabs/filter_tab.dart';
import 'package:hwenti_flutter/screens/tabs/home_tab.dart';
import 'package:hwenti_flutter/screens/tabs/notifications_tab.dart';
import 'package:hwenti_flutter/screens/tabs/profile_tab.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final filter = context.watch<FilterProvider>();
    final locale = context.watch<LocaleProvider>();

    if (auth.needsMerchantSetup) {
      return const MerchantSetupScreen();
    }

    const tabs = <Widget>[
      HomeTab(),
      FilterTab(),
      FavoritesTab(),
      NotificationsTab(),
      ProfileTab(),
    ];

    final safeIndex = filter.currentTabIndex.clamp(0, tabs.length - 1);

    final navItems = <_NavDockItem>[
      _NavDockItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: locale.t('home'),
      ),
      _NavDockItem(
        icon: Icons.tune_rounded,
        activeIcon: Icons.manage_search_rounded,
        label: locale.t('filter'),
      ),
      _NavDockItem(
        icon: Icons.favorite_outline_rounded,
        activeIcon: Icons.favorite_rounded,
        label: locale.t('favorites'),
      ),
      _NavDockItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: locale.t('notifications'),
      ),
      _NavDockItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: locale.t('profile'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false,
      body: IndexedStack(
        index: safeIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (idx) {
              final item = navItems[idx];
              final isSelected = idx == safeIndex;

              return Expanded(
                child: BouncyTap(
                  scaleDown: 0.92,
                  onTap: () => filter.setTabIndex(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEEF2FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 22,
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF64748B),
                        )
                            .animate(target: isSelected ? 1 : 0)
                            .scaleXY(
                              begin: 1.0,
                              end: 1.14,
                              duration: 240.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          width: isSelected ? 16 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
  );
  }
}

class _NavDockItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavDockItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
