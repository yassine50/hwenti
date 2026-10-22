import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  String? _governorateId;
  String? _governorateName;
  String? _governorateNameAr;
  String? _governorateNameFr;
  String? _delegationId;
  String? _delegationName;
  String? _delegationNameAr;
  String? _delegationNameFr;
  String? _tradeType;
  String? _merchantId;
  String? _merchantName;
  String _searchQuery = '';
  String? _focusedSection;
  int _currentTabIndex = 0;

  String? get governorateId => _governorateId;
  String? get governorateName => _governorateName;
  String? get delegationId => _delegationId;
  String? get delegationName => _delegationName;
  String? get tradeType => _tradeType;
  String? get merchantId => _merchantId;
  String? get merchantName => _merchantName;
  String get searchQuery => _searchQuery;
  String? get focusedSection => _focusedSection;
  int get currentTabIndex => _currentTabIndex;

  String? localizedGovernorateName(String locale) {
    if (_governorateId == null || _governorateId!.isEmpty) return null;
    if (locale == 'ar' &&
        _governorateNameAr != null &&
        _governorateNameAr!.isNotEmpty) {
      return _governorateNameAr;
    }
    if (locale != 'ar' &&
        _governorateNameFr != null &&
        _governorateNameFr!.isNotEmpty) {
      return _governorateNameFr;
    }
    return _governorateName;
  }

  String? localizedDelegationName(String locale) {
    if (_delegationId == null || _delegationId!.isEmpty) return null;
    if (locale == 'ar' &&
        _delegationNameAr != null &&
        _delegationNameAr!.isNotEmpty) {
      return _delegationNameAr;
    }
    if (locale != 'ar' &&
        _delegationNameFr != null &&
        _delegationNameFr!.isNotEmpty) {
      return _delegationNameFr;
    }
    return _delegationName;
  }

  bool get hasActiveFilters =>
      (_governorateId != null && _governorateId!.isNotEmpty) ||
      (_delegationId != null && _delegationId!.isNotEmpty) ||
      (_tradeType != null && _tradeType!.isNotEmpty) ||
      (_merchantId != null && _merchantId!.isNotEmpty) ||
      _searchQuery.trim().isNotEmpty;

  void setTabIndex(int index, {String? focusSection}) {
    _currentTabIndex = index;
    if (focusSection != null) {
      _focusedSection = focusSection;
    }
    notifyListeners();
  }

  void clearFocusedSection() {
    _focusedSection = null;
  }

  void setGovernorate(
    String? id,
    String? name, {
    String? nameAr,
    String? nameFr,
  }) {
    final changed = _governorateId != id;
    _governorateId = id;
    _governorateName = name;
    _governorateNameAr = nameAr ?? name;
    _governorateNameFr = nameFr ?? name;
    if (changed) {
      _delegationId = null;
      _delegationName = null;
      _delegationNameAr = null;
      _delegationNameFr = null;
    }
    notifyListeners();
  }

  void setDelegation(
    String? id,
    String? name, {
    String? nameAr,
    String? nameFr,
  }) {
    _delegationId = id;
    _delegationName = name;
    _delegationNameAr = nameAr ?? name;
    _delegationNameFr = nameFr ?? name;
    notifyListeners();
  }

  void setTradeType(String? type) {
    _tradeType = type;
    notifyListeners();
  }

  void setMerchant(String? id, String? name) {
    _merchantId = id;
    _merchantName = name;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    if (_searchQuery == q) return;
    _searchQuery = q;
    notifyListeners();
  }

  void clearAll() {
    _governorateId = null;
    _governorateName = null;
    _governorateNameAr = null;
    _governorateNameFr = null;
    _delegationId = null;
    _delegationName = null;
    _delegationNameAr = null;
    _delegationNameFr = null;
    _tradeType = null;
    _merchantId = null;
    _merchantName = null;
    _searchQuery = '';
    _focusedSection = null;
    notifyListeners();
  }
}
