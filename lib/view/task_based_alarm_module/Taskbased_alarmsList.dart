import 'dart:io';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/view/task_based_alarm_module/View_MyTask_details.dart';
import 'package:alarm_fyp/view/task_based_alarm_module/setTask_Location.dart';
import 'package:alarm_fyp/widgets/CustomButton_Blue.dart';
import 'package:alarm_fyp/widgets/common_drawer.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:alarm_fyp/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../models/taskModel.dart';
import '../../utils/constants.dart';

class Mytask extends StatefulWidget {
  const Mytask({super.key});

  @override
  State<Mytask> createState() => _MytaskState();
}

class _MytaskState extends State<Mytask> {
  List<TaskAlarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> alarmsData = prefs.getStringList('task_alarms') ?? [];
    final alarms = alarmsData.map((e) => TaskAlarm.fromJson(e)).toList();

    setState(() {
      _alarms = alarms;
    });
  }

  Future<void> _deleteTask(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the deleted alarm
    TaskAlarm deletedAlarm = _alarms[index];

    // Load existing deleted alarms from bin
    final List<String> binData = prefs.getStringList('alarm_bin') ?? [];
    binData.add(deletedAlarm.toJson());

    // Save updated bin list
    await prefs.setStringList('alarm_bin', binData);

    // Remove from active alarms
    _alarms.removeAt(index);

    // Save updated active alarms
    final updatedData = _alarms.map((e) => e.toJson()).toList();
    await prefs.setStringList('task_alarms', updatedData);

    setState(() {});
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
         //   backgroundColor: kPrimaryColor.withOpacity(0.3),
            title: Text('Delete Alarm', style: CustomTextStyle.headingStyle().copyWith(
              color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),),
            content: Text(
              'Are you sure you want to delete this alarm?',
              style: CustomTextStyle.GeneralStyle().copyWith(
                color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
              ),
              TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  _deleteTask(index);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(int index) {
    final alarm = _alarms[index];
    final TextEditingController nameController = TextEditingController(text: alarm.name);
    final TextEditingController descController = TextEditingController(text: alarm.description);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final dialogBackground = Theme.of(context).dialogBackgroundColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBackground,
        title: Text(
          'Edit Alarm',
          style: CustomTextStyle.headingStyle().copyWith(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              hintText: "Alarm Name",
              labelText: "Alarm Name",
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: descController,
              hintText: "Alarm Description",
              labelText: "Description",
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
          ),
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              TaskAlarm updatedAlarm = TaskAlarm(
                name: nameController.text,
                description: descController.text,
                lat: alarm.lat,
                long: alarm.long,
                location: alarm.location,
                time: alarm.time,
                days: alarm.days,
                imagePath: alarm.imagePath,
                isFavourit: alarm.isFavourit,
              );

              setState(() {
                _alarms[index] = updatedAlarm;
              });

              final updatedData = _alarms.map((e) => e.toJson()).toList();
              await prefs.setStringList('task_alarms', updatedData);

              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(color: kPrimaryColor.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Common_Drawer(),
      appBar: CustomAppbar(title: 'Your Tasks'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _alarms.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/empty-box.png",height: 100,),
                      SizedBox(height: 10,),
                      Text(
                        "No tasks found ",
                        style: CustomTextStyle.subtitleStyle(),
                      ),

                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: _alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = _alarms[index];
                    return Stack(
                      children: [
                        InkWell(
                          // onLongPress: () {
                          //   _confirmDelete(index);
                          // },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ViewMytaskDetails(alarm: alarm),
                              ),
                            );
                          },
                          child: Card(
                            shadowColor: kTextGrey,
                            elevation: 10,
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
                                      : Icon(
                                        Icons.alarm,
                                        size: 60,
                                        color: kPrimaryColor,
                                      ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildRowTitleValue(
                                          "Alarm Name: ",
                                          alarm.name,
                                        ),
                                        const SizedBox(height: 3),
                                        _buildRowTitleValue(
                                          "Location: ",
                                          alarm.location,
                                        ),
                                        const SizedBox(height: 3),
                                        _buildRowTitleValue(
                                          "Time: ",
                                          alarm.time,
                                        ),
                                        const SizedBox(height: 3),
                                        _buildRowTitleValue(
                                          "Days: ",
                                          alarm.days.join(', '),
                                          maxLines: 2,
                                        ),
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
                              final prefs =
                                  await SharedPreferences.getInstance();

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
                              final updatedData =
                                  _alarms.map((e) => e.toJson()).toList();
                              await prefs.setStringList(
                                'task_alarms',
                                updatedData,
                              );
                            },

                            child: CircleAvatar(
                              backgroundColor: Colors.grey.withOpacity(0.4),
                              radius: 18,
                              child: Icon(
                                alarm.isFavourit
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 50,
                          child: GestureDetector(
                            onTap: () {
                              _showEditDialog(index);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.withOpacity(0.4),
                              radius: 18,
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 96,
                          child: GestureDetector(
                            onTap: () {
                              _confirmDelete(index);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.withOpacity(0.4),
                              radius: 18,
                              child: Icon(
                                Icons.delete,
                                size: 18,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
      floatingActionButton: CustomButton_Blue(
        text: 'Add New Task Alarm',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettaskLocation()),
          ).then((_) {
            _loadTasks(); // Call the function when user returns
          });
        },
        width: 50.w,
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
