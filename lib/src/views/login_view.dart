import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/settings_controller.dart';
import 'package:abotrack_fl/src/views/dashboard_view.dart';
import 'package:abotrack_fl/src/components/Login/password_input.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override

  /// Builds the login view.
  ///
  /// The login view contains a text field for the user to enter their password.
  /// If the password is not set, the user is prompted to create a new password.
  /// If the password is set, the user is prompted to enter the existing password.
  /// If the user presses the "Enter" button, the user is navigated to the
  /// dashboard if the password is correct, or an error message is shown if the
  /// password is incorrect or empty.
  Widget build(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);

    final isPasswordSet = settingsController.password != null;

    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 150, 142, 142),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 80, vertical: 153),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPasswordSet
                        ? 'Enter Your Password'
                        : 'Create a New Password',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),
                  PasswordInput(controller: passwordController),
                  const SizedBox(height: 215),
                  ElevatedButton(
                    onPressed: () {
                      final password = passwordController.text;
                      if (password.isNotEmpty) {
                        if (isPasswordSet) {
                          // Validate existing password
                          if (password == settingsController.password) {
                            // Navigate to the Dashboard if the password matches
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DashboardView()),
                            );
                          } else {
                            // Show error message if password is incorrect
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Incorrect password. Please try again.'),
                              ),
                            );
                          }
                        } else {
                          // Set up new password
                          settingsController.updatePassword(password);
                          // Navigate to the Dashboard
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashboardView()),
                          );
                        }
                      } else {
                        // Show error message if password is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password cannot be empty.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF495A4E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size(160, 50),
                    ),
                    child: Text(
                      isPasswordSet ? 'Enter' : 'Create Password',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
