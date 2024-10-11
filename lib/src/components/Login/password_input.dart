import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const PasswordInput({super.key, required this.controller});

  @override

  /// Builds a widget for inputting a password.
  ///
  /// The widget is a TextFormField with a style and decoration that
  /// adapts to the current theme.
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme

    return Container(
      width: 254,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor, // Use card color from the current theme
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme
              .colorScheme.onSurface, // Use color from theme for input text
        ),
        decoration: InputDecoration(
          hintText: 'Enter your Password',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor, // Use theme's hint color
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
