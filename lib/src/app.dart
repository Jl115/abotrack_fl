import 'package:abotrack_fl/src/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'controller/settings_controller.dart';

// Define the global navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  /// The build method for the app widget.
  ///
  /// This method is responsible for creating the MaterialApp and setting up the
  /// initial route, theme, and localization delegates. The initial route is
  /// determined by whether a password is set or not. If a password is set, the
  /// app starts at the login route. Otherwise, it starts at the login route.
  ///
  /// The theme is set to either light or dark depending on the theme mode set by
  /// the user. The theme is also set to dark if the user has not set a theme mode
  /// yet.
  ///
  /// The onGenerateRoute callback is used to generate the routes for the app.
  /// The callback takes a RouteSettings object and returns a Route object. The
  /// Route object is used by the MaterialApp to generate the route.
  ///
  /// The onGenerateTitle callback is used to generate the title for the app. The
  /// title is determined by the locale of the app.
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);

    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        // Determine the initial route based on whether a password exists
        final initialRoute = settingsController.password == null
            ? AppRoutes.login
            : AppRoutes
                .login; // Always start with LoginView to enter the password

        return MaterialApp(
          navigatorKey: navigatorKey, // Attach the navigatorKey here
          restorationScopeId: 'app',
          initialRoute: initialRoute, // Set initial route to login
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return AppRoutes.generateRoute(routeSettings, settingsController);
          },
        );
      },
    );
  }
}
