import 'dart:convert';
import 'dart:io';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/view/task_based_alarm_module/View_MyTask_details.dart';
import 'package:alarm_fyp/view/task_based_alarm_module/setTask_Location.dart';
import 'package:alarm_fyp/widgets/CustomButton_Blue.dart';
import 'package:alarm_fyp/widgets/common_drawer.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../models/taskModel.dart';

class FavTaskAlarms extends StatefulWidget {
  const FavTaskAlarms({super.key});

  @override
  State<FavTaskAlarms> createState() => _FavTaskAlarmsState();
}

class _FavTaskAlarmsState extends State<FavTaskAlarms> {
  List<TaskAlarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> alarmsData = prefs.getStringList('task_alarms') ?? [];

    final alarms = alarmsData
        .map((e) => TaskAlarm.fromJson(e))
        .where((alarm) => alarm.isFavourit) // Filter only favorites
        .toList();

    setState(() {
      _alarms = alarms;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _alarms.isEmpty
            ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/empty-box.png",height: 100,),
                SizedBox(height: 10,),
                Text("No tasks found ",style: CustomTextStyle.subtitleStyle(),),
              ],
            ))
            : ListView.builder(
          itemCount: _alarms.length,
          itemBuilder: (context, index) {
            final alarm = _alarms[index];
            return Stack(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ViewMytaskDetails(alarm: alarm),
                    ));
                  },
                  child: Card(
                    shadowColor: kTextGrey,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          alarm.imagePath != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(alarm.imagePath!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Icon(Icons.alarm, size: 60, color: kPrimaryColor),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRowTitleValue("Alarm Name: ", alarm.name),
                                const SizedBox(height: 3),

                                _buildRowTitleValue(
                                  "Time: ",
                                  alarm.time,
                                ),
                                const SizedBox(height: 3),
                                _buildRowTitleValue("Location: ", alarm.location),
                                const SizedBox(height: 3),
                                _buildRowTitleValue(
                                    "Days: ", alarm.days.join(', '), maxLines: 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Delete Icon Outside Top-Right
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();

                      // Toggle the favorite value
                      TaskAlarm updatedAlarm = TaskAlarm(
                        name: alarm.name,
                        description: alarm.description,
                        lat: alarm.lat,
                        long: alarm.long,
                        location: alarm.location,
                        time: alarm.time,
                        days: alarm.days,
                        imagePath: alarm.imagePath,
                        isFavourit: !alarm.isFavourit,
                      );

                      // Update the alarm in the list
                      setState(() {
                        _alarms[index] = updatedAlarm;
                      });

                      // Save updated list to SharedPreferences
                      final updatedData = _alarms.map((e) => e.toJson()).toList();
                      await prefs.setStringList('task_alarms', updatedData);

                      _loadTasks();

                    },

                    child: CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.4),
                      radius: 18,
                      child: Icon(alarm.isFavourit ? Icons.favorite : Icons.favorite_border,
                          size: 18, color: Colors.red),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
              fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: CustomTextStyle.headingStyle(
                fontSize: 16.sp, fontWeight: FontWeight.bold).copyWith(
              color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          )
        ),
      ],
    );
  }}



