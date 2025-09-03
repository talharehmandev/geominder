import 'package:alarm_fyp/view/task_based_alarm_module/Taskbased_alarmsList.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NotificationHandler {
  static const MethodChannel _channel = MethodChannel('com.example.alarm_fyp/launch');

  static Future<void> handleMethodCall(BuildContext context) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'launchApp') {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Mytask(),
        ));
      }
    });
  }
}