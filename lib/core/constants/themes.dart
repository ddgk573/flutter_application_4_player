import "package:flutter/material.dart";

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color.fromARGB(255, 12, 140, 214);
  static const Color secondaryColor = Color.fromARGB(255, 44, 3, 226);
  static const Color backgroundColorL = Color.fromARGB(255, 240, 240, 240);
  static const Color backgroundColorD = Color.fromARGB(255, 30, 30, 30);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColorL,
      ),
      scaffoldBackgroundColor: backgroundColorL,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 240, 240, 240),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.black,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColorD,
      ),
      scaffoldBackgroundColor: backgroundColorD,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(255, 20, 20, 20),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}
