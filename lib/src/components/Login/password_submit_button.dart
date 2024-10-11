import 'package:flutter/material.dart';

class PasswordSubmitButton extends StatelessWidget {
  const PasswordSubmitButton({super.key});

  @override

  /// Builds a submit button with the text "Enter".
  ///
  /// The button is of the color #495A4E, with a rounded rectangle border
  /// with a radius of 16, and a minimum size of 160x50. The text is white,
  /// with a font size of 12, and the font family is Inter.
  ///
  /// The `onPressed` callback is not set, so it must be set manually.
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
