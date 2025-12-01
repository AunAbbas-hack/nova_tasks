// lib/features/settings/viewmodels/settings_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsViewModel extends ChangeNotifier {
  // keys for SharedPreferences
  static const _kDarkMode = 'dark_mode';
  static const _kDefaultHomeView = 'default_home_view';
  static const _kReminderHour = 'reminder_hour';
  static const _kReminderMinute = 'reminder_minute';
  static const _kLanguage = 'language';

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _darkMode = false; // switch state
  bool get darkMode => _darkMode;

  String _defaultHomeView = 'Today'; // Today / Week
  String get defaultHomeView => _defaultHomeView;

  TimeOfDay _defaultReminderTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get defaultReminderTime => _defaultReminderTime;

  String _language = 'English';
  String get language => _language;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool(_kDarkMode) ?? false;
    _defaultHomeView = prefs.getString(_kDefaultHomeView) ?? 'Today';

    final h = prefs.getInt(_kReminderHour);
    final m = prefs.getInt(_kReminderMinute);
    if (h != null && m != null) {
      _defaultReminderTime = TimeOfDay(hour: h, minute: m);
    }

    _language = prefs.getString(_kLanguage) ?? 'English';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
    // NOTE: yahan se tum later global theme change kara sakte ho
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

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, value);
  }

  /// Logout: Firebase signOut + clear login flag (agar koi ho) etc.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // agar tum login flag SharedPreferences me rakh rahe ho to yahan clear karo
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('logged_in');
  }

  String? get currentUserName =>
      FirebaseAuth.instance.currentUser?.displayName;

  String? get currentUserEmail =>
      FirebaseAuth.instance.currentUser?.email;
}
