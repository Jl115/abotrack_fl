import 'package:abotrack_fl/src/views/abo_view.dart';
import 'package:abotrack_fl/src/views/dashboard_view.dart';
import 'package:abotrack_fl/src/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:abotrack_fl/src/views/settings_view.dart';
import 'package:abotrack_fl/src/controller/settings_controller.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String abo = '/abo';

  static Route<dynamic> generateRoute(
      RouteSettings routeSettings, SettingsController settingsController) {
    // Specify type
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
          builder: (context) => const AboView(),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (context) => SettingsView(),
          settings: routeSettings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => DashboardView(),
          settings: routeSettings,
        );
    }
  }
}
