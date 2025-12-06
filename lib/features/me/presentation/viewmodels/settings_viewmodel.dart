// lib/features/settings/viewmodels/settings_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsViewModel extends ChangeNotifier {
  // SharedPrefs Keys
  static const _kDarkMode = 'dark_mode';
  static const _kDefaultHomeView = 'default_home_view';
  static const _kReminderHour = 'reminder_hour';
  static const _kReminderMinute = 'reminder_minute';
  static const _kLanguage = 'language'; // ALWAYS "language"

  bool _isLoading = true;
  bool get isLoading => _isLoading;



  bool _darkMode = false;
  bool get darkMode => _darkMode;

  String _defaultHomeView = 'Today';
  String get defaultHomeView => _defaultHomeView;

  TimeOfDay _defaultReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get defaultReminderTime => _defaultReminderTime;

  SettingsViewModel() {
    _loadSettings();
  }

  Locale _locale =  Locale("ur");   // Locale("en")
  String _languageCode = "en";               // "en" or "ur"
  String get languageCode => _languageCode;
  Locale get locale => _locale;
  // 🔥 Load all settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool(_kDarkMode) ?? false;
    _defaultHomeView = prefs.getString(_kDefaultHomeView) ?? 'Today';

    final h = prefs.getInt(_kReminderHour);
    final m = prefs.getInt(_kReminderMinute);
    if (h != null && m != null) {
      _defaultReminderTime = TimeOfDay(hour: h, minute: m);
    }

    // 🔥 Load saved language CORRECTLY
    _languageCode = prefs.getString(_kLanguage) ?? "en";
    _locale = Locale(_languageCode);

    _isLoading = false;
    notifyListeners();
  }
  // 🔥 FINAL LANGUAGE HANDLER
  Future<void> setLanguage(String code) async {
    _languageCode = code;        // en / ur
    _locale = Locale(_languageCode);  // Locale("en") or Locale("ur")
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, code);
    notifyListeners();
  }
  // Theme, Reminder, HomeView
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<void> setDefaultHomeView(String value) async {
    _defaultHomeView = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultHomeView, value);
  }

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
