import 'package:abotrack_fl/src/components/base/drawer_component.dart';
import 'package:abotrack_fl/src/service/notification_service.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      drawer: drawer.customDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // App Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AboTrack',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track and manage your subscriptions',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Theme Settings Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Appearance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Theme',
                        style: theme.textTheme.bodyLarge,
                      ),
                      DropdownButton<ThemeMode>(
                        dropdownColor: theme.cardColor,
                        value: settingsController.themeMode,
                        onChanged: settingsController.updateThemeMode,
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Data Management Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storage_outlined,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Data Management',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _exportData(context, settingsController),
                          icon: const Icon(Icons.download),
                          label: const Text('Export'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _importData(context, settingsController),
                          icon: const Icon(Icons.upload),
                          label: const Text('Import'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Account Settings Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Security',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showChangePasswordDialog(context, settingsController),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_reset),
                          const SizedBox(width: 8),
                          Text(
                            'Change Password',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Export data dialog
  void _exportData(BuildContext context, SettingsController settingsController) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Export Data'),
        content: Text('Choose export format:', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement export logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
              Navigator.pop(ctx);
            },
            child: const Text('JSON'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement export logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
              Navigator.pop(ctx);
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  /// Import data dialog
  void _importData(BuildContext context, SettingsController settingsController) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Import Data'),
        content: Text('Choose import format:', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement import logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon!')),
              );
              Navigator.pop(ctx);
            },
            child: const Text('JSON'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement import logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon!')),
              );
              Navigator.pop(ctx);
            },
            child: const Text('CSV'),
          ),
        ],
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
