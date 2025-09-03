// import 'package:alarm/alarm.dart';
// import 'package:alarm/model/alarm_settings.dart';
// import 'package:flutter/material.dart';
//
// class AlarmService {
//   static int _generateUniqueId() {
//     return DateTime.now().millisecondsSinceEpoch % 100000;
//   }
//
//   static Future<void> scheduleAlarm({
//     required String alarmName,
//     required String alarmDescription,
//   }) async {
//     final alarmSettings = AlarmSettings(
//       id: _generateUniqueId(),
//       dateTime: DateTime.now(),
//       assetAudioPath: "assets/bedside-clock-alarm.mp3",
//       loopAudio: true,
//       vibrate: true,
//       volumeSettings: VolumeSettings.fade(
//         volume: 0.8,
//         fadeDuration: const Duration(seconds: 5),
//         volumeEnforced: false,
//       ),
//       notificationSettings: NotificationSettings(
//         title: alarmName,
//         body: alarmDescription,
//         stopButton: 'Stop Alarm',
//         icon: 'notification_icon',
//         iconColor: const Color(0xff862778),
//       ),
//     );
//
//     await Alarm.set(alarmSettings: alarmSettings);
//     print('Alarm set for ${DateTime.now()},');
//   }
//
//
// }

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';

class AlarmService {
  // Generate a unique ID using timestamp
  static int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }

  /// Schedule an alarm with a custom title and body
  static Future<void> scheduleAlarm({
    required String title,      // Notification title
    required String body,       // Notification body
    DateTime? alarmTime,        // Optional custom alarm time
  }) async {
    final alarmSettings = AlarmSettings(
      id: _generateUniqueId(),
      dateTime: alarmTime ?? DateTime.now().add(Duration(seconds: 10)), // fallback to now + 10s
      assetAudioPath: "assets/bedside-clock-alarm.mp3",
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 5),
        volumeEnforced: false,
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop Alarm',
        icon: 'notification_icon',
        iconColor: const Color(0xff862778),
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    print('Alarm set for ${alarmSettings.dateTime}');
  }
}
