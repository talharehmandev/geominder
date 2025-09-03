import 'dart:io';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/taskModel.dart';

class taskBin extends StatefulWidget {
  const taskBin({Key? key}) : super(key: key);

  @override
  State<taskBin> createState() => _taskBinState();
}

class _taskBinState extends State<taskBin> {
  List<TaskAlarm> _deletedAlarms = [];

  @override
  void initState() {
    super.initState();
    _loadDeletedAlarms();
  }

  Future<void> _loadDeletedAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> binData = prefs.getStringList('alarm_bin') ?? [];
    final alarms = binData.map((e) => TaskAlarm.fromJson(e)).toList();
    setState(() {
      _deletedAlarms = alarms;
    });
  }

  Future<void> _deleteFromBin(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _deletedAlarms.removeAt(index);
    });
    final updatedBin = _deletedAlarms.map((e) => e.toJson()).toList();
    await prefs.setStringList('alarm_bin', updatedBin);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Deleted Alarms'),
      //   backgroundColor: isDark ? Colors.grey[900] : Colors.red.shade700,
      //   foregroundColor: Colors.white,
      // ),
      body: _deletedAlarms.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/empty-box.png",height: 100,),
            SizedBox(height: 10,),
            Text(
              'No deleted task found',
              style: TextStyle(fontSize: 16, color: textColor?.withOpacity(0.6)),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _deletedAlarms.length,
        itemBuilder: (context, index) {
          final alarm = _deletedAlarms[index];
          return Card(
            shadowColor: kTextGrey,

            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: cardColor,
            elevation: 3,
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: alarm.imagePath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(alarm.imagePath!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(Icons.alarm, size: 40, color: kPrimaryColor),
              title: Text(
                alarm.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
              ),
              subtitle: Text(
                "${alarm.time} • ${alarm.location}",
                style: TextStyle(color: textColor?.withOpacity(0.7)),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Delete Permanently',
                color: Colors.red,
                onPressed: () => _deleteFromBin(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
