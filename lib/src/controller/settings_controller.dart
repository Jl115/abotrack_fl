import 'package:abotrack_fl/src/service/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsController with ChangeNotifier {
  final SettingsService _settingsService;
  late ThemeMode _themeMode;
  String? _password;

  SettingsController(this._settingsService);

  ThemeMode get themeMode => _themeMode;
  String? get password => _password;

  Future<void> loadSettings() async {
    final settings = await _settingsService.loadSettings();
    _themeMode = settings.themeMode;
    _password = settings.password;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updatePassword(String newPassword) async {
    _password = newPassword;
    notifyListeners();
    await _settingsService.updatePassword(newPassword);
  }
}
