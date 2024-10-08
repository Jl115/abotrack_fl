import 'package:flutter/material.dart';

class PasswordSubmitButton extends StatelessWidget {
  const PasswordSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Handle submit action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF495A4E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(160, 50),
      ),
      child: const Text(
        'Enter',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
