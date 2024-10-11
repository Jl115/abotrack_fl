import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor:
      const Color(0xFFB2A8A8), // Background color matching the image
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFFE0E0E0), // Light drawer color
    elevation: 0, // No elevation for aesthetics
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor:
        Color(0xFFE0BDF6), // Light purple accent matching FAB color
    foregroundColor: Colors.black, // Icon color for visibility
  ),
  textTheme: const TextTheme(
    bodyLarge:
        TextStyle(color: Colors.black), // Dark text color for readability
    bodyMedium: TextStyle(
        color: Colors.black87), // Slightly lighter black for secondary text
    titleMedium: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold), // Titles and headings
    titleSmall: TextStyle(color: Colors.grey), // Lighter gray for minor labels
    displayMedium: TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold), // Main heading text
    displaySmall: TextStyle(color: Colors.grey), // Subtle display text for UI
    displayLarge: TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold), // Larger headings
    bodySmall: TextStyle(color: Colors.grey), // Body text for minor information
    labelSmall: TextStyle(
        color: Colors.black54), // Labels for input hints and small text
    labelLarge: TextStyle(
        color: Colors.black54), // Labels for input hints and small text
    labelMedium: TextStyle(
        color: Colors.black54), // Labels for input hints and small text
  ),
  cardColor: const Color(0xFFE0E0E0), // Card background color similar to image

  // Adding button theme to the light theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(
          0xFF5D5D5D), // Button background color, matching gray buttons in image
      foregroundColor: Colors.white, // Button text color for better contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24), // Increased padding for better usability
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blueAccent, // Accent color for links and buttons
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFE0E0E0), // Light fill color for input fields
    hintStyle: TextStyle(
        color: Color(0xFF5D5D5D)), // Hint text color to match button background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none, // No border for cleaner look
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor:
      const Color(0xFF1E1E1E), // Slightly lighter dark background
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2A2A2A), // Darker app bar for contrast
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1E1E1E), // Slightly darker for contrast
    elevation: 0, // No elevation for aesthetics
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.tealAccent,
    foregroundColor: Colors.black, // Text color for better visibility
  ),
  textTheme: const TextTheme(
    bodyLarge:
        TextStyle(color: Color(0xFFE0E0E0)), // Light gray for readability
    bodyMedium: TextStyle(color: Color(0xFFCCCCCC)), // Slightly darker gray
    titleMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold), // Titles and headings
    titleSmall: TextStyle(
        color: Color.fromARGB(255, 112, 109, 109)), // Button text color
    displayMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold), // Text in the login screen
    displaySmall: TextStyle(
        color:
            Color.fromARGB(255, 112, 109, 109)), // Text in the login Screen(),
    displayLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold), // Text in the login screen
    bodySmall: TextStyle(
        color: Color.fromARGB(255, 112, 109, 109)), // Text in the login screen
    labelSmall: TextStyle(
        color: Color.fromARGB(255, 187, 183, 183)), // Text in the login screen
    labelLarge: TextStyle(
        color: Color.fromARGB(255, 112, 109, 109)), // Text in the login screen
    labelMedium: TextStyle(
        color: Color.fromARGB(255, 112, 109, 109)), // Text in the login screen
  ),
  cardColor: const Color(0xFF2A2A2A), // Card background color

  // Adding button theme to the dark theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.tealAccent, // Button background color
      foregroundColor: Colors.black, // Button text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24), // Increased padding for better usability
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.tealAccent, // Text button color
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2A2A2A), // Input field background color
    hintStyle:
        TextStyle(color: Color(0xFF888888)), // Hint text color for readability
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none, // No border for cleaner look
    ),
  ),
);
