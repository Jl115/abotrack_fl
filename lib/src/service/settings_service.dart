import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class Settings {
  ThemeMode themeMode;
  String? password;

  Settings({required this.themeMode, this.password});

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.toString().split('.').last,
        'password': password,
      };

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.${json['themeMode']}',
      ),
      password: json['password'],
    );
  }
}

class SettingsService {
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

  Future<void> saveSettings(Settings settings) async {
    final file = await _getSettingsFile();
    final jsonString = json.encode(settings.toJson());
    await file.writeAsString(jsonString);
  }

  Future<ThemeMode> themeMode() async {
    final settings = await loadSettings();
    return settings.themeMode;
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final settings = await loadSettings();
    settings.themeMode = themeMode;
    await saveSettings(settings);
  }

  Future<String?> getPassword() async {
    final settings = await loadSettings();
    return settings.password;
  }

  Future<void> updatePassword(String newPassword) async {
    final settings = await loadSettings();
    settings.password = newPassword;
    await saveSettings(settings);
  }

  Future<File> _getSettingsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/settings.json');
  }
}
