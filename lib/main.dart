import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:abotrack_fl/src/controller/settings_controller.dart';
import 'package:abotrack_fl/src/service/settings_service.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  AboController();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => settingsController,
        ),
        ChangeNotifierProvider(
          create: (context) => AboController(), // Use the singleton instance
        ),
      ],
      child: MyApp(),
    ),
  );
}
