import 'dart:convert';
import 'package:flutter/material.dart';

class Settings {
  ThemeMode themeMode;

  Settings({required this.themeMode});

  // Convert Settings object to JSON
  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.toString().split('.').last, // Save as string
      };

  // Convert JSON to Settings object
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: ThemeMode.values
          .firstWhere((e) => e.toString() == 'ThemeMode.${json['themeMode']}'),
    );
  }
}
