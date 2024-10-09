import 'dart:convert';
import 'package:flutter/material.dart';

class Settings {
  ThemeMode themeMode;
  String? password; // Add password to the settings model

  Settings({required this.themeMode, this.password});

  // Convert Settings object to JSON
  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.toString().split('.').last,
        'password': password,
      };

  // Convert JSON to Settings object
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.${json['themeMode']}',
      ),
      password: json['password'],
    );
  }
}
