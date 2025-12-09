// lib/features/settings/viewmodels/settings_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../l10n/app_localizations.dart';

class SettingsViewModel extends ChangeNotifier {
  // SharedPrefs Keys
  static const _kDarkMode = 'dark_mode';
  static const _kDefaultHomeView = 'default_home_view';
  static const _kReminderHour = 'reminder_hour';
  static const _kReminderMinute = 'reminder_minute';
  static const _kLanguage = 'language';

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _darkMode = false;
  bool get darkMode => _darkMode;

  // ✅ FIX: Store key ('today' or 'weekly')
  String _defaultHomeView = 'today';
  String get defaultHomeView => _defaultHomeView;

  TimeOfDay _defaultReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get defaultReminderTime => _defaultReminderTime;

  Locale _locale = const Locale("en");
  String _languageCode = "en";
  String get languageCode => _languageCode;
  Locale get locale => _locale;

  SettingsViewModel() {
    _loadSettings();
  }

  // 🔥 Load all settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool(_kDarkMode) ?? false;

    // ✅ Load key ('today' or 'weekly')
    _defaultHomeView = prefs.getString(_kDefaultHomeView) ?? 'today';

    final h = prefs.getInt(_kReminderHour);
    final m = prefs.getInt(_kReminderMinute);
    if (h != null && m != null) {
      _defaultReminderTime = TimeOfDay(hour: h, minute: m);
    }

    _languageCode = prefs.getString(_kLanguage) ?? "en";
    _locale = Locale(_languageCode);

    _isLoading = false;
    notifyListeners();
  }

  // ✅ NEW: Get localized home view text (only Today/Weekly)
  String getLocalizedHomeView(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    switch (_defaultHomeView) {
      case 'today':
        return loc.today;
      case 'weekly':
        return loc.week;
      default:
        return loc.today;
    }
  }

  // 🔥 Language handler
  Future<void> setLanguage(String code) async {
    _languageCode = code;
    _locale = Locale(_languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, code);
    notifyListeners();
  }

  // Theme
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  // ✅ Save key ('today' or 'weekly')
  Future<void> setDefaultHomeView(String value) async {
    _defaultHomeView = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultHomeView, value);
  }

  // Reminder time
  Future<void> setDefaultReminderTime(TimeOfDay time) async {
    _defaultReminderTime = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kReminderHour, time.hour);
    await prefs.setInt(_kReminderMinute, time.minute);
  }

  // Logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  String? get currentUserName =>
      FirebaseAuth.instance.currentUser?.displayName;

  String? get currentUserEmail =>
      FirebaseAuth.instance.currentUser?.email;
}