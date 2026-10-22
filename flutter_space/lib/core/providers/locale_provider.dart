import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hwenti_flutter/core/l10n/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _storageKey = 'locale';
  static const String _selectedFlagKey = 'hwenti_has_selected_language';

  String _locale = 'ar';
  bool _hasSelectedLanguage = false;
  bool _isInitialized = false;

  LocaleProvider() {
    _loadSavedLocale();
  }

  String get locale => _locale;
  bool get isRTL => _locale == 'ar';
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isInitialized => _isInitialized;
  TextDirection get textDirection =>
      _locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  String t(String key) => AppStrings.tr(_locale, key);

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      _hasSelectedLanguage = prefs.getBool(_selectedFlagKey) ?? false;
      if (saved == 'ar' || saved == 'fr') {
        _locale = saved!;
      }
    } catch (_) {
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(String newLocale) async {
    if (newLocale != 'ar' && newLocale != 'fr') return;
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, _locale);
    } catch (_) {}
  }

  /// Called from LanguageSelectionScreen when the user confirms their language.
  Future<void> confirmLanguageSelection(String chosenLocale) async {
    if (chosenLocale == 'ar' || chosenLocale == 'fr') {
      _locale = chosenLocale;
    }
    _hasSelectedLanguage = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, _locale);
      await prefs.setBool(_selectedFlagKey, true);
    } catch (_) {}
  }

  Future<void> toggleLocale() async {
    final next = _locale == 'ar' ? 'fr' : 'ar';
    await setLocale(next);
  }
}
