import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override

  /// Builds a submit button with the text "Enter".
  ///
  /// The button uses theme properties for color and text style to adapt to
  /// light and dark modes. The button has a rounded rectangle border
  /// with a radius of 16 and a minimum size of 254x50.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme

    return ElevatedButton(
      onPressed: () {
        // Handle submit action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor, // Use primary color from theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(254, 50),
      ),
      child: Text(
        'Enter',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme
              .onPrimary, // Text color that contrasts with button color
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
