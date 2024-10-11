import 'package:abotrack_fl/src/views/abo_view.dart';
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

  /// Creates a Drawer widget with a custom layout.
  ///
  /// The Drawer widget is used as the side menu for the app.
  ///
  /// The layout consists of a column with three TextButton widgets.
  /// The first button navigates to the DashboardView, the second button
  /// navigates to the AboView and the third button navigates to the SettingsView.
  ///
  /// The Drawer widget is also given a custom width and background color.
  ///
  /// The function returns a Drawer widget with the above layout and properties.
  Drawer customDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 150, 142, 142),
      width: 150,
      child: Column(
        children: [
          const SizedBox(height: 50, width: 60),
          SizedBox(
            height: 60,
            width: 100,
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
            height: 60,
            width: 100,
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboView(),
                    ),
                  );
                },
                child: const Text('All Abo\'s'),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 60,
            width: 100,
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
