import "package:flutter/material.dart";

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color.fromARGB(255, 12, 140, 214);
  static const Color secondaryColor = Color.fromARGB(255, 44, 3, 226);
  static const Color backgroundColorL = Color.fromARGB(255, 240, 240, 240);
  static const Color backgroundColorD = Color.fromARGB(255, 30, 30, 30);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColorL,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColorL,
      snackBarTheme: _snackBarTheme(colorScheme),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 240, 240, 240),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColorD,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColorD,
      snackBarTheme: _snackBarTheme(colorScheme),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white,
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.secondaryContainer,
      contentTextStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      actionTextColor: colorScheme.onSecondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(12),
    );
  }
}
