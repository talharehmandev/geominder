import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:alarm_fyp/main.dart';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/view/settingsView.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../models/taskModel.dart';
import '../../providers/alarmSound_Provider.dart';
import '../../providers/vibration_provider.dart';
import '../../widgets/CustomButton_Blue.dart';
import '../../widgets/custom_text_field.dart';
import '../bottom_bar.dart';

class AddTaskbasedAlarm extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const AddTaskbasedAlarm({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  @override
  State<AddTaskbasedAlarm> createState() => _AddTaskbasedAlarmState();
}

class _AddTaskbasedAlarmState extends State<AddTaskbasedAlarm> {
  final TextEditingController _alarmNameController = TextEditingController();
  final TextEditingController _alarmdescriptionController =
      TextEditingController();

  TimeOfDay? _selectedTime;
  List<String> _selectedDays = [];
  bool myVibration = true;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  File? _selectedImage;

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isVibrationOn = context.watch<VibrationProvider>().isVibrationOn;
    final alarmPath = context.read<AlarmSoundProvider>().selectedAlarm;
    final alarmVolume = context.read<AlarmSoundProvider>().alarmVolume;
    return Scaffold(
      appBar: CustomAppbar(
        title: "Task Based Alarm",
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: kPrimaryColor),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: Icon(Icons.settings, color: kPrimaryColor),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ',
                  style: CustomTextStyle.subtitleStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  widget.locationName,
                  style: CustomTextStyle.headingStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ).copyWith(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                  // overflow: TextOverflow.ellipsis,
                  // maxLines: 1,
                ),
              ],
            ),
            SizedBox(height: 5),
            CustomTextField(
              controller: _alarmNameController,
              labelText: 'Alarm Name',
              hintText: 'Enter alarm name',
            ),
            SizedBox(height: 8),
            CustomTextField(
              maxLines: 4,
              controller: _alarmdescriptionController,
              labelText: 'Alarm Description',
              hintText: 'Enter alarm description',
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: kPrimaryColor),
                    SizedBox(width: 8),
                    Text(
                      _selectedTime == null
                          ? 'Select alarm time'
                          : _formatTime(_selectedTime!),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Day Selection
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
                      onSelected: (_) => _toggleDay(day),
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),

            // Image Picker
            Text(
              'Add Image (Optional):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _selectedImage == null
                ? ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("Pick Image"),
                  onPressed: _pickImage,
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.file(_selectedImage!, height: 200),
                    TextButton.icon(
                      icon: Icon(Icons.delete_forever, color: Colors.red),
                      label: Text(
                        "Remove Image",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: _removeImage,
                    ),
                  ],
                ),
            SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: CustomButton_Blue(
        text: 'Save Alarm',
        onTap: () async {
          if (_alarmNameController.text.isEmpty || _selectedTime == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please fill in all required fields")),
            );
            return;
          }

          final alarm = TaskAlarm(
            lat: widget.latitude.toString(),
            location: widget.locationName,
            long: widget.longitude.toString(),
            name: _alarmNameController.text.trim(),
            description: _alarmdescriptionController.text.trim(),
            time: _formatTime(_selectedTime!),
            days: _selectedDays,
            imagePath: _selectedImage?.path,
            isFavourit: false,
          );

          final prefs = await SharedPreferences.getInstance();
          final List<String> alarms = prefs.getStringList('task_alarms') ?? [];

          alarms.add(alarm.toJson());

          await prefs.setStringList('task_alarms', alarms);

          final timeString = _formatTime(_selectedTime!); // e.g., 6:52 PM
          final timeParts = timeString.split(' ');
          final hourMinute = timeParts[0].split(':');
          int hour = int.parse(hourMinute[0]);
          int minute = int.parse(hourMinute[1]);
          final period = timeParts[1];

          if (period == 'PM' && hour != 12) {
            hour += 12;
          } else if (period == 'AM' && hour == 12) {
            hour = 0;
          }
          final now = DateTime.now();
          DateTime alarmDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );

          // If time already passed today, set for tomorrow
          if (alarmDateTime.isBefore(now)) {
            alarmDateTime = alarmDateTime.add(Duration(days: 1));
          }

          final alarmSettings = AlarmSettings(
            id: (alarms.length + 1),
            dateTime: alarmDateTime,
            assetAudioPath: '$alarmPath',
            loopAudio: true,

            vibrate: isVibrationOn,
            volumeSettings: VolumeSettings.fade(
              volume: alarmVolume,
              fadeDuration: Duration(seconds: 3),
              volumeEnforced: false,
            ),
            notificationSettings: NotificationSettings(
              title: 'Alarm: ${alarm.name} is ringing!',
              body: 'Alarm Description "${alarm.description}"',
              stopButton: 'Stop the alarm',

             // largeIcon: const DrawableResourceAndroidBitmap('app_icon'), // optional
              icon: 'app_icon',
              iconColor: kPrimaryColor,
            ),
          );

          Alarm.set(alarmSettings: alarmSettings).then((_) {
            print(
              'Alarm set for ${alarmDateTime.toString()} with ID: ${alarms.length + 1}}',
            );
          });
          ExamplePage.startService2();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Alarm saved successfully!")));

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BottomNavBar()),
            (route) => false,
          );
        },
        width: 50.w,
      ),
    );
  }
}
