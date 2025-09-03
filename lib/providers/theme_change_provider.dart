import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Load the saved theme mode from SharedPreferences
  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedTheme = prefs.getInt('themeMode');
    _themeMode = ThemeMode.values[storedTheme ?? 0]; // Default to system if not set
    notifyListeners();
  }

  // Save the selected theme mode to SharedPreferences
  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.index); // Save the theme index
    notifyListeners();
  }
}
