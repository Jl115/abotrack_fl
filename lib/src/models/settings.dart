import 'package:flutter/material.dart';

class Settings {
  ThemeMode themeMode;
  String? password;

  Settings({required this.themeMode, this.password});

  /// Converts this [Settings] object to a JSON-serializable map.
  ///
  /// The map contains two keys: 'themeMode' and 'password'. The value of
  /// 'themeMode' is the string representation of [themeMode] without the
  /// type name prefix, and the value of 'password' is the string password.
  ///
  /// The map can be serialized to JSON using [jsonEncode].
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
