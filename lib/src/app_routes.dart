import 'package:abotrack_fl/src/views/abo_view.dart';
import 'package:abotrack_fl/src/views/dashboard_view.dart';
import 'package:abotrack_fl/src/views/login_view.dart';
import 'package:abotrack_fl/src/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:abotrack_fl/src/controller/settings_controller.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String abo = '/abo';

  /// Generates a route based on the given [RouteSettings] and [SettingsController].
  ///
  /// If the user has not set a password, the login page is returned for all routes
  /// except the login page.
  ///
  /// The following routes are supported:
  ///
  /// * [login]: The login page
  /// * [dashboard]: The dashboard page
  /// * [abo]: The ABO page
  /// * [settings]: The settings page
  ///
  /// For all other routes, the login page is returned.
  static Route<dynamic> generateRoute(
      RouteSettings routeSettings, SettingsController settingsController) {
    // If the user has not set a password, default to the login page
    if (settingsController.password == null && routeSettings.name != login) {
      return MaterialPageRoute(
        builder: (context) => const LoginView(),
        settings: routeSettings,
      );
    }

    // Specify routes
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginView(),
          settings: routeSettings,
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (context) => DashboardView(),
          settings: routeSettings,
        );
      case abo:
        return MaterialPageRoute(
          builder: (context) => AboView(),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (context) => SettingsView(),
          settings: routeSettings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const LoginView(),
          settings: routeSettings,
        );
    }
  }
}
