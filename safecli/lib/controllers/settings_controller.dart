import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsController extends ChangeNotifier {
  SettingsModel _settings = SettingsModel();
  bool _isLoading = false;

  SettingsModel get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      _settings = SettingsModel(
        autoScan: prefs.getBool('autoScan') ?? true,
        notifications: prefs.getBool('notifications') ?? true,
        language: prefs.getString('language') ?? 'ar',
        safeBrowsing: prefs.getBool('safeBrowsing') ?? true,
        darkMode: prefs.getBool('darkMode') ?? false,
        autoUpdate: prefs.getBool('autoUpdate') ?? true,
        saveHistory: prefs.getBool('saveHistory') ?? true,
        scanTimeout: prefs.getInt('scanTimeout') ?? 30,
        scanLevel: prefs.getString('scanLevel') ?? 'standard',
      );
    } catch (e) {
      debugPrint('خطأ في تحميل الإعدادات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('autoScan', _settings.autoScan);
      await prefs.setBool('notifications', _settings.notifications);
      await prefs.setString('language', _settings.language);
      await prefs.setBool('safeBrowsing', _settings.safeBrowsing);
      await prefs.setBool('darkMode', _settings.darkMode);
      await prefs.setBool('autoUpdate', _settings.autoUpdate);
      await prefs.setBool('saveHistory', _settings.saveHistory);
      await prefs.setInt('scanTimeout', _settings.scanTimeout);
      await prefs.setString('scanLevel', _settings.scanLevel);
    } catch (e) {
      debugPrint('خطأ في حفظ الإعدادات: $e');
    }
  }

  Future<void> toggleAutoScan(bool value) async {
    _settings = _settings.copyWith(autoScan: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _settings = _settings.copyWith(notifications: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> changeLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleSafeBrowsing(bool value) async {
    _settings = _settings.copyWith(safeBrowsing: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleAutoUpdate(bool value) async {
    _settings = _settings.copyWith(autoUpdate: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleSaveHistory(bool value) async {
    _settings = _settings.copyWith(saveHistory: value);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setScanTimeout(int seconds) async {
    _settings = _settings.copyWith(scanTimeout: seconds);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setScanLevel(String level) async {
    _settings = _settings.copyWith(scanLevel: level);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _settings = SettingsModel();
    await _saveSettings();
    notifyListeners();
  }
}
