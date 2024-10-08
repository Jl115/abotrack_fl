import 'package:abotrack_fl/src/components/Login/password_input.dart';
import 'package:abotrack_fl/src/components/Login/submit_button.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const String login = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 150, 142, 142),
        child: const Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 153),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 20),
                  PasswordInput(),
                  SizedBox(height: 215),
                  SubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
