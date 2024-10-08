import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/service/settings_service.dart';
import 'src/controller/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialization here

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  runApp(
    ChangeNotifierProvider(
      create: (context) => settingsController,
      child: MyApp(),
    ),
  );
}
