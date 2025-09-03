// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AlarmSoundProvider with ChangeNotifier {
//   String _selectedAlarm = 'assets/bedside-clock-alarm.mp3'; // Default
//
//   String get selectedAlarm => _selectedAlarm;
//
//   AlarmSoundProvider() {
//     _loadAlarm();
//   }
//
//   Future<void> _loadAlarm() async {
//     final prefs = await SharedPreferences.getInstance();
//     _selectedAlarm = prefs.getString('selected_alarm') ?? _selectedAlarm;
//     notifyListeners();
//   }
//
//   Future<void> setAlarm(String alarmPath) async {
//     _selectedAlarm = alarmPath;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_alarm', alarmPath);
//     notifyListeners();
//   }
// }
import 'package:flutter/cupertino.dart';

class AlarmSoundProvider with ChangeNotifier {
  String _selectedAlarm = 'assets/bedside-clock-alarm.mp3';
  double _alarmVolume = 1.0; // Default volume

  String get selectedAlarm => _selectedAlarm;
  double get alarmVolume => _alarmVolume;

  void setAlarm(String value) {
    _selectedAlarm = value;
    notifyListeners();
  }

  void setVolume(double value) {
    _alarmVolume = value;
    notifyListeners();
  }
}
