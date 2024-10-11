import 'package:abotrack_fl/src/components/base/drawer_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  static const routeName = '/settings';

  final DrawerComponent drawer = DrawerComponent();

  @override

  /// Builds the settings view.
  ///
  /// The settings view contains a dropdown for the theme and an elevated button
  /// for changing the password.
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 50,
                      width: 60,
                      child: Center(
                        child: Text(
                          'Theme',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
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
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () =>
                      _showChangePasswordDialog(context, settingsController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF495A4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a dialog for changing the password.
  ///
  /// This dialog allows the user to input a new password and confirm it.
  /// If the user presses the "Cancel" button, the dialog is simply closed.
  /// If the user presses the "Save" button, the user is prompted to enter
  /// both the new password and the confirmation password. If the passwords
  /// do not match, the user is shown a snackbar error message.
  /// If the passwords do match, the password is updated and the user is shown
  /// a snackbar success message. The dialog is then closed.
  void _showChangePasswordDialog(
      BuildContext context, SettingsController settingsController) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both password fields'),
                    ),
                  );
                } else if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                    ),
                  );
                } else {
                  settingsController.updatePassword(newPassword);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully'),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
