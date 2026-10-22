import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hwenti_flutter/core/cache/app_cache_service.dart';
import 'package:hwenti_flutter/core/providers/auth_provider.dart';
import 'package:hwenti_flutter/core/providers/filter_provider.dart';
import 'package:hwenti_flutter/core/providers/locale_provider.dart';
import 'package:hwenti_flutter/core/theme/app_theme.dart';
import 'package:hwenti_flutter/screens/auth/login_screen.dart';
import 'package:hwenti_flutter/screens/main_shell_screen.dart';
import 'package:hwenti_flutter/screens/merchant_setup_screen.dart';
import 'package:hwenti_flutter/screens/onboarding/language_selection_screen.dart';
import 'package:hwenti_flutter/screens/onboarding/onboarding_screen.dart';
import 'package:hwenti_flutter/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppCacheService.instance.init();
  runApp(const HwentiApp());
}

class HwentiApp extends StatefulWidget {
  const HwentiApp({super.key});

  @override
  State<HwentiApp> createState() => _HwentiAppState();
}

class _HwentiAppState extends State<HwentiApp> {
  bool _splashCompleted = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: Consumer2<LocaleProvider, AuthProvider>(
        builder: (context, localeProvider, authProvider, _) {
          return MaterialApp(
            title: 'حوانتي - Hwenti',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(localeProvider.locale),
            locale: Locale(localeProvider.locale),
            supportedLocales: const [
              Locale('ar'),
              Locale('fr'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: localeProvider.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: _buildRootScreen(localeProvider, authProvider),
          );
        },
      ),
    );
  }

  Widget _buildRootScreen(
    LocaleProvider localeProvider,
    AuthProvider auth,
  ) {
    // 1. Dedicated Splash Screen at App Launch (warms up cache in parallel)
    if (!_splashCompleted || auth.isLoading || !localeProvider.isInitialized) {
      return SplashScreen(
        isAr: localeProvider.locale == 'ar',
        onFinished: () {
          if (mounted && !_splashCompleted) {
            setState(() => _splashCompleted = true);
          }
        },
      );
    }

    // 2. Language Selection Screen at the Beginning (saved once selected)
    if (!localeProvider.hasSelectedLanguage) {
      return const LanguageSelectionScreen();
    }

    // 3. Auto Sign-In: If user already logged in once, go straight into the app!
    if (auth.isAuthenticated) {
      if (auth.needsMerchantSetup) {
        return const MerchantSetupScreen();
      }
      return const MainShellScreen();
    }

    // 4. First-time Onboarding or Login / Guest Mode
    if (!auth.hasSeenOnboarding) {
      return const OnboardingScreen();
    }
    if (!auth.isGuestMode) {
      return const LoginScreen();
    }
    return const MainShellScreen();
  }
}
