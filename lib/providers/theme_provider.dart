import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }

  Future<void> setThemeMode(bool isDark) async {
    _isDarkMode = isDark;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'CircularStd',
    primaryColor: const Color(0xFF4FC3A1),
    scaffoldBackgroundColor: const Color(0xFFF5F9FF),
    cardColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4FC3A1),
      secondary: Color(0xFF3A9B7A),
      surface: Colors.white,
      background: Color(0xFFF5F9FF),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF2E7D5A),
      onBackground: Color(0xFF2E3E5C),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4FC3A1),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'CircularStd',
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontSize: 18,
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),

    iconTheme: const IconThemeData(color: Color(0xFF4FC3A1)),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF2E3E5C)),
      bodyMedium: TextStyle(color: Color(0xFF2E3E5C)),
      titleLarge: TextStyle(
        color: Color(0xFF2E7D5A),
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'CircularStd',
    primaryColor: const Color(0xFF4FC3A1),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4FC3A1),
      secondary: Color(0xFF3A9B7A),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE0E0E0),
      onBackground: Color(0xFFE0E0E0),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'CircularStd',
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontSize: 18,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),

    iconTheme: const IconThemeData(color: Color(0xFF4FC3A1)),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
      titleLarge: TextStyle(
        color: Color(0xFF4FC3A1),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
