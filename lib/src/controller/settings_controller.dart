import 'package:abotrack_fl/src/service/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsController with ChangeNotifier {
  final SettingsService _settingsService;
  late ThemeMode _themeMode;
  String? _password;

  SettingsController(this._settingsService);

  ThemeMode get themeMode => _themeMode;
  String? get password => _password;

  /// Loads the settings from the device's file system and updates the internal
  /// state of the controller. The [ChangeNotifier] interface is used to notify
  /// any listeners of the controller that the state has changed.
  ///
  /// This method is typically called when the controller is first created.
  ///
  Future<void> loadSettings() async {
    final settings = await _settingsService.loadSettings();
    _themeMode = settings.themeMode;
    _password = settings.password;
    notifyListeners();
  }

  /// Updates the theme mode of the app to the given [ThemeMode].
  ///
  /// If the given [ThemeMode] is the same as the current theme mode, this
  /// function does nothing. Otherwise, the internal state of the controller is
  /// updated and any listeners of the controller are notified. The theme mode
  /// is also saved to the device's file system.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Updates the password of the app to the given [newPassword].
  ///
  /// The given [newPassword] is stored in the internal state of the controller,
  /// and any listeners of the controller are notified. The password is also
  /// saved to the device's file system.
  ///
  /// If the given [newPassword] is the same as the current password, this
  /// function does nothing.
  Future<void> updatePassword(String newPassword) async {
    _password = newPassword;
    notifyListeners();
    await _settingsService.updatePassword(newPassword);
  }
}
