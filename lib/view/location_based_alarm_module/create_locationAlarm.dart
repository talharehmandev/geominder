import 'dart:convert';
import 'package:alarm_fyp/main.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/widgets/CustomButton_Blue.dart';
import 'package:alarm_fyp/widgets/custom_text_field.dart';
import 'package:alarm_fyp/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../utils/Primary_text.dart';
import '../../widgets/custom_appBar.dart';

class locationAlarm extends StatefulWidget {
  final LatLng location;
  final String locationName;

  const locationAlarm({
    super.key,
    required this.location,
    required this.locationName,
  });

  @override
  _locationAlarmState createState() => _locationAlarmState();
}

class _locationAlarmState extends State<locationAlarm> {
  final TextEditingController _alarmNameController = TextEditingController();
  final TextEditingController _alarmdescriptionController = TextEditingController();
  bool isfavorte = false;

  List<String> _selectedDays = [];
  var radius = 50;

  void increaseRadius() {
    radius = radius + 10;
    setState(() {});
  }

  void decreaseRadius() {
    if (radius >= 55) {
      radius = radius - 10;
      setState(() {});
    }
  }

  // For Days selection
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
   // _alarmNameController.text = widget.locationName;
  }


  // Function to toggle days
  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> saveAlarmToPrefs(Map<String, dynamic> newAlarm) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingAlarms = prefs.getStringList('alarms') ?? [];

    // Convert the map to JSON string
    String jsonAlarm = jsonEncode(newAlarm);

    // Add new alarm
    existingAlarms.add(jsonAlarm);

    // Save updated list
    await prefs.setStringList('alarms', existingAlarms);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.location);
    return Scaffold(
      appBar: CustomAppbar(
        title: "Location based Alarm",
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: kPrimaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Alarm Name TextField
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task Location: ',style: CustomTextStyle.subtitleStyle(fontWeight: FontWeight.bold,fontSize: 20.sp),),
                Text(widget.locationName,style: CustomTextStyle.headingStyle(fontWeight: FontWeight.bold,fontSize: 20.sp).copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),),
              ],
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _alarmNameController,
              labelText: 'Alarm Name',
              hintText: 'Enter alarm name',
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _alarmdescriptionController,
              labelText: 'Alarm Description',
              hintText: 'Enter alarm description',
              maxLines: 4,
            ),
            SizedBox(height: 16),

            Text(
              'Days:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children:
                  days.map((day) {
                    return FilterChip(
                      selectedColor: kPrimaryColor,
                      label: Text(day),
                      selected: _selectedDays.contains(day),
                      onSelected: (selected) {
                        _toggleDay(day);
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Radius",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Spacer(),
                IconButton(
                  onPressed: () {
                    decreaseRadius();
                  },
                  icon: Icon(Icons.remove_circle),
                  color: kPrimaryColor,
                ),
                Text("$radius",style: CustomTextStyle.headingStyle().copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),),
                IconButton(
                  onPressed: () {
                    increaseRadius();
                  },
                  icon: Icon(Icons.add_circle, color: kPrimaryColor),
                ),
              ],
            ),


          ],
        ),
      ),
      floatingActionButton:   CustomButton_Blue(
        text: 'Save Alarm',
        width: 40.w,
        onTap: () async {
          if (_alarmNameController.text.isNotEmpty &&
              _selectedDays.isNotEmpty) {
            saveAlarmToPrefs({
              'latitude': widget.location.latitude,
              'longitude': widget.location.longitude,
              'alarm_name': _alarmNameController.text,
              'alarm_description':_alarmdescriptionController.text,
              'alarm_days': _selectedDays,
              'alarm_radius': radius,
              'is_favorite': isfavorte,
              'location_name': widget.locationName,
            });


            Utils().toastmessage(
              message: "Alarm saved successfully!",
              isError: false,
            );
            Navigator.pop(context);
            ExamplePage.startService2();

            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ExampleApp(),));
          } else {
            Utils().toastmessage(
              message: "Please fill all fields correctly!",
              isError: true,
            );
          }
        },
      ),
    );
  }
}
