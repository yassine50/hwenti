import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hwenti_flutter/core/api/api_client.dart';
import 'package:hwenti_flutter/core/cache/app_cache_service.dart';
import 'package:hwenti_flutter/core/models/models.dart';

class AuthProvider extends ChangeNotifier {
  static const String _onboardingKey = 'hwenti_has_seen_onboarding';
  static const String _cachedUserKey = 'hwenti_cached_user_json_v1';

  AppUser? _user;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  bool _isGuestMode = false;

  AuthProvider() {
    _restoreSession();
  }

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuestMode => _isGuestMode;
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isMerchant => _user?.role == 'merchant';
  bool get needsMerchantSetup =>
      _user != null && _user!.role == 'merchant' && !_user!.merchantSetupComplete;

  Future<void> _persistUserToCache(AppUser? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user == null) {
        await prefs.remove(_cachedUserKey);
      } else {
        await prefs.setString(
          _cachedUserKey,
          jsonEncode(user.toJson()),
        );
      }
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {}
  }

  /// Marks onboarding as persisted in storage as soon as it is shown on first install
  /// so it never appears again on subsequent app launches.
  Future<void> markOnboardingShownOnFirstOpen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {}
  }

  Future<void> enterGuestMode() async {
    _isGuestMode = true;
    await completeOnboarding();
  }

  Future<void> _restoreSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      await AppCacheService.instance.init();
      final prefs = await SharedPreferences.getInstance();
      _hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;

      final token = await ApiClient.instance.getToken();
      if (token != null && token.isNotEmpty) {
        // 1. Instant 0ms Auto Sign-In from cached user JSON if available
        final cachedUserJson = prefs.getString(_cachedUserKey);
        if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
          try {
            final map = jsonDecode(cachedUserJson);
            if (map is Map) {
              _user = AppUser.fromJson(Map<String, dynamic>.from(map));
              _hasSeenOnboarding = true;
              _isLoading = false;
              notifyListeners();
              // Verify and refresh silently in the background
              _verifySessionInBackground();
              return;
            }
          } catch (_) {}
        }

        // 2. Fallback: fetch user profile from backend
        final freshUser = await ApiClient.instance.getMe();
        _user = freshUser;
        _hasSeenOnboarding = true;
        await _persistUserToCache(freshUser);
      }
    } on ApiException catch (e) {
      if (e.status == 401) {
        await ApiClient.instance.clearToken();
        await _persistUserToCache(null);
        _user = null;
      }
    } catch (_) {
      // Do not wipe saved token on transient offline/network error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _verifySessionInBackground() async {
    try {
      final freshUser = await ApiClient.instance.getMe();
      _user = freshUser;
      await _persistUserToCache(freshUser);
      notifyListeners();
    } on ApiException catch (e) {
      if (e.status == 401) {
        await ApiClient.instance.clearToken();
        await _persistUserToCache(null);
        _user = null;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> login(String email, String password) async {
    final loggedInUser = await ApiClient.instance.login(email, password);
    _user = loggedInUser;
    _isGuestMode = false;
    await _persistUserToCache(loggedInUser);
    await completeOnboarding();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final createdUser = await ApiClient.instance.signup(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    _user = createdUser;
    _isGuestMode = false;
    await _persistUserToCache(createdUser);
    await completeOnboarding();
  }

  Future<void> signInWithGoogle({
    required String email,
    required String name,
    String role = 'visitor',
  }) async {
    final googleUser = await ApiClient.instance.googleAuth(
      email: email,
      name: name,
      role: role,
    );
    _user = googleUser;
    _isGuestMode = false;
    await _persistUserToCache(googleUser);
    await completeOnboarding();
  }

  Future<void> logout() async {
    await ApiClient.instance.clearToken();
    await _persistUserToCache(null);
    _user = null;
    _isGuestMode = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final freshUser = await ApiClient.instance.getMe();
      _user = freshUser;
      await _persistUserToCache(freshUser);
      notifyListeners();
    } catch (_) {}
  }
}
