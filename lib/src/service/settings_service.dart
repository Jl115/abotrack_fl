import 'dart:convert';
import 'dart:io';
import 'package:abotrack_fl/src/models/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class SettingsService {
  /// Loads the app settings from the device's file system. If the settings file
  /// does not exist or if there is an error loading the file, a default
  /// [Settings] object is returned with the theme mode set to
  /// [ThemeMode.system].
  Future<Settings> loadSettings() async {
    try {
      final file = await _getSettingsFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return Settings.fromJson(jsonMap);
      } else {
        return Settings(themeMode: ThemeMode.system);
      }
    } catch (e) {
      return Settings(themeMode: ThemeMode.system);
    }
  }

  /// Saves the app settings to the device's file system. The settings are
  /// converted to JSON and written to a file named "settings.json" in the app's
  /// application document directory. If the file does not exist, it is created.
  /// If there is an error writing to the file, the error is not propagated.
  Future<void> saveSettings(Settings settings) async {
    final file = await _getSettingsFile();
    final jsonString = json.encode(settings.toJson());
    await file.writeAsString(jsonString);
  }

  /// Loads the current theme mode from the device's file system.
  ///
  /// Returns [ThemeMode.system] if there is an error loading the theme mode.
  Future<ThemeMode> themeMode() async {
    final settings = await loadSettings();
    return settings.themeMode;
  }

  /// Updates the app's theme mode to the given [ThemeMode].
  ///
  /// The theme mode is saved to the device's file system and will be used the
  /// next time the app is started. If there is an error saving the theme mode,
  /// the error is not propagated.
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final settings = await loadSettings();
    settings.themeMode = themeMode;
    await saveSettings(settings);
  }

  /// Loads the password from the device's file system.
  ///
  /// Returns null if there is an error loading the password.
  Future<String?> getPassword() async {
    final settings = await loadSettings();
    return settings.password;
  }

  /// Updates the password to the given [newPassword].
  ///
  /// The password is saved to the device's file system and will be used the
  /// next time the app is started. If there is an error saving the password,
  /// the error is not propagated.
  Future<void> updatePassword(String newPassword) async {
    final settings = await loadSettings();
    settings.password = newPassword;
    await saveSettings(settings);
  }

  /// Returns a [File] object pointing to the file that contains the app's
  /// settings. The file is named "settings.json" and is located in the app's
  /// application document directory.
  Future<File> _getSettingsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/settings.json');
  }
}
