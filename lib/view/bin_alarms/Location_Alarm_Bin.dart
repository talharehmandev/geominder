import 'dart:convert';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:alarm_fyp/utils/Primary_text.dart';

class locationbin extends StatefulWidget {
  const locationbin({super.key});

  @override
  _locationbinState createState() => _locationbinState();
}

class _locationbinState extends State<locationbin> {
  List<Map<String, dynamic>> deletedAlarms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedAlarms();
  }

  // Load deleted alarms from the 'location_alarm_bin' in SharedPreferences
  Future<void> _loadDeletedAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedDeletedAlarms = prefs.getStringList('location_alarm_bin') ?? [];

    setState(() {
      deletedAlarms = storedDeletedAlarms
          .map((alarmJson) => jsonDecode(alarmJson) as Map<String, dynamic>)
          .toList();
      isLoading = false;
    });
  }

  // Delete alarm from the SharedPreferences
  Future<void> _deleteAlarm(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedDeletedAlarms = prefs.getStringList('location_alarm_bin') ?? [];

    // Remove the selected alarm from the list
    storedDeletedAlarms.removeAt(index);

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('location_alarm_bin', storedDeletedAlarms);

    // Update the local list and UI
    setState(() {
      deletedAlarms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : deletedAlarms.isEmpty
          ? Center(
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
            Image.asset("assets/empty-box.png",height: 100,),
            SizedBox(height: 10,),
            Text(
              'No deleted task found',
              style: TextStyle(fontSize: 16,),
            ),
                    ],
                  ),
          )
      :ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: deletedAlarms.length,
        itemBuilder: (context, index) {
          final alarm = deletedAlarms[index];
          final days = (alarm['alarm_days'] as List?)?.join(', ') ?? "";
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.alarm, size: 60, color: kPrimaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRowTitleValue("Alarm Name: ", alarm['alarm_name']),
                        const SizedBox(height: 3),
                        _buildRowTitleValue("Destination: ", alarm['alarm_description']),
                        const SizedBox(height: 3),
                        _buildRowTitleValue("Location: ", alarm['location_name']),
                        const SizedBox(height: 3),
                        _buildRowTitleValue("Days: ", "$days", maxLines: 2),
                        const SizedBox(height: 3),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Alarm"),
                            content: Text("Are you sure you want to permanently delete this alarm?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteAlarm(index); // Delete the alarm
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRowTitleValue(String title, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CustomTextStyle.subtitleStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: CustomTextStyle.headingStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ).copyWith(
              color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
