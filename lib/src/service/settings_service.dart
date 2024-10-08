import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    final file = await _getSettingsFile();
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == 'ThemeMode.${jsonData['themeMode']}',
        orElse: () => ThemeMode.system, // Default to system if not found
      );
    }
    return ThemeMode.system;
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final file = await _getSettingsFile();
    final jsonData = {'themeMode': themeMode.toString().split('.').last};
    await file.writeAsString(json.encode(jsonData));
  }

  Future<File> _getSettingsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/settings.json');
  }
}
