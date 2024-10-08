import 'package:abotrack_fl/src/components/base/drawer_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  SettingsView({Key? key}) : super(key: key);

  static const routeName = '/settings';

  final DrawerComponent drawer = DrawerComponent();

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 150, 142, 142),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 150, 142, 142),
      ),
      drawer: drawer.customDrawer(context),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 435,
            height: 896,
            decoration: ShapeDecoration(
              color: const Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: 50,
                      width: 60,
                      child: const Center(
                        child: Text(
                          'Theme',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                  const SizedBox(width: 50),
                  DropdownButton<ThemeMode>(
                    dropdownColor: const Color.fromARGB(255, 103, 79, 79),
                    value: settingsController.themeMode,
                    onChanged: settingsController.updateThemeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
