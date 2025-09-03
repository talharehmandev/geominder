import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VibrationProvider with ChangeNotifier {
  bool _isVibrationOn = true;

  bool get isVibrationOn => _isVibrationOn;

  VibrationProvider() {
    _loadVibration();
  }

  void _loadVibration() async {
    final prefs = await SharedPreferences.getInstance();
    _isVibrationOn = prefs.getBool('myVibration') ?? true;
    notifyListeners();
  }

  void toggleVibration(bool value) async {
    _isVibrationOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('myVibration', value);
    notifyListeners();
  }
}
