import 'package:abotrack_fl/src/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controller/settings_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the SettingsController from the Provider
    final settingsController = Provider.of<SettingsController>(context);

    return ListenableBuilder(
      listenable:
          settingsController, // Set the listenable to the SettingsController
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController
              .themeMode, // Use the themeMode from the controller
          onGenerateRoute: (RouteSettings routeSettings) {
            return AppRoutes.generateRoute(routeSettings, settingsController);
          },
        );
      },
    );
  }
}
