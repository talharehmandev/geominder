import 'dart:convert';

class TaskAlarm {
  final String name;
  final String description;
  final String time;
  final String long;
  final String lat;
  final String location;
  final List<String> days;
  final String? imagePath;
  final bool isFavourit;

  TaskAlarm({
    required this.name,
    required this.description,
    required this.lat,
    required this.long,
    required this.location,
    required this.time,
    required this.isFavourit,
    required this.days,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'lat': lat,
    'long': long,
    'isFavourit': isFavourit,
    'time': time,
    'location': location,
    'days': days,
    'imagePath': imagePath,
  };

  static TaskAlarm fromMap(Map<String, dynamic> map) => TaskAlarm(
    name: map['name'],
    description: map['description'],
    lat: map['lat'],
    isFavourit: map['isFavourit'],
    location: map['location'],
    long: map['long'],
    time: map['time'],
    days: List<String>.from(map['days']),
    imagePath: map['imagePath'],
  );

  String toJson() => json.encode(toMap());

  static TaskAlarm fromJson(String source) =>
      TaskAlarm.fromMap(json.decode(source));
}
