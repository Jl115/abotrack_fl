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
    final theme = Theme.of(context); // Get the current theme

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor:
            theme.appBarTheme.backgroundColor, // Use theme AppBar color
      ),
      drawer: drawer.customDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: 435,
          height: 896,
          decoration: ShapeDecoration(
            color: theme.cardColor, // Use theme card color
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
                    SizedBox(
                      height: 50,
                      width: 60,
                      child: Center(
                        child: Text(
                          'Theme',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ), // Use theme text style and customize as needed
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    DropdownButton<ThemeMode>(
                      dropdownColor:
                          theme.cardColor, // Adapt dropdown background to theme
                      value: settingsController.themeMode,
                      onChanged: settingsController.updateThemeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(
                            'System Theme',
                            style: theme
                                .textTheme.bodyMedium, // Use theme text style
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(
                            'Light Theme',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(
                            'Dark Theme',
                            style: theme.textTheme.bodyMedium,
                          ),
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
                    backgroundColor:
                        theme.primaryColor, // Use theme's primary color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(200, 50),
                  ),
                  child: Text(
                    'Change Password',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme
                          .onPrimary, // Text color should contrast with button color
                      fontSize: 16,
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
  void _showChangePasswordDialog(
      BuildContext context, SettingsController settingsController) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context); // Get the current theme
        return AlertDialog(
          backgroundColor:
              theme.cardColor, // Use the card color for dialog background
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle:
                      theme.textTheme.bodyMedium, // Use theme text style
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: theme.textTheme.bodyMedium,
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
