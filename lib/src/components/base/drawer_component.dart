import 'package:abotrack_fl/src/views/dashboard_view.dart';
import 'package:abotrack_fl/src/views/settings_view.dart';
import 'package:flutter/material.dart';

class DrawerComponent {
  static DrawerComponent? _instance;
  DrawerComponent._internal();

  factory DrawerComponent() {
    _instance ??= DrawerComponent._internal();
    return _instance!;
  }

  // Accept BuildContext as a parameter
  Drawer customDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 150, 142, 142),
      width: 150,
      child: ListView(
        children: [
          SizedBox(
            height: 50,
            width: 60,
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardView(),
                    ),
                  );
                },
                child: const Text('Dashboard'),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 60,
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsView(),
                    ),
                  );
                },
                child: const Text('Settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
