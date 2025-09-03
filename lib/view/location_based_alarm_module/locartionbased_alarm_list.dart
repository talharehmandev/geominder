import 'dart:convert';
import 'package:alarm_fyp/main.dart';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/widgets/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appBar.dart';
import 'locationBased_alarmDetails.dart';

class Location_basedAlarmList extends StatefulWidget {
  const Location_basedAlarmList({super.key});

  @override
  State<Location_basedAlarmList> createState() =>
      _Location_basedAlarmListState();
}

class _Location_basedAlarmListState extends State<Location_basedAlarmList> {
  List<Map<String, dynamic>> alarms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarmData();
  }

  Future<void> _loadAlarmData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedAlarms = prefs.getStringList('alarms') ?? [];

    setState(() {
      alarms =
          storedAlarms
              .map((alarmJson) => jsonDecode(alarmJson) as Map<String, dynamic>)
              .toList();
      isLoading = false;
    });
  }

  Future<void> _deleteAlarm(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Save alarm to 'location_alarm_bin' before deleting
    List<String> binAlarms = prefs.getStringList('location_alarm_bin') ?? [];
    binAlarms.add(jsonEncode(alarms[index]));
    await prefs.setStringList('location_alarm_bin', binAlarms);

    // Now delete the alarm from the current list
    alarms.removeAt(index);
    List<String> updatedAlarms = alarms.map((alarm) => jsonEncode(alarm)).toList();
    await prefs.setStringList('alarms', updatedAlarms);

    setState(() {}); // Update UI
  }

  Future<void> _markFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Toggle the favorite status
    alarms[index]['is_favorite'] = !(alarms[index]['is_favorite'] == true);

    // Save back to SharedPreferences
    List<String> updatedAlarms =
        alarms.map((alarm) => jsonEncode(alarm)).toList();
    await prefs.setStringList('alarms', updatedAlarms);

    setState(() {}); // Update UI
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                  Navigator.of(ctx).pop();
                  _deleteAlarm(index);
                  ExamplePage.startService2();
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
    final alarm = alarms[index];
    final nameController = TextEditingController(text: alarm['alarm_name']);
    final descController = TextEditingController(text: alarm['alarm_description']);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final dialogBackground = Theme.of(context).dialogBackgroundColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Edit Alarm',
          style: CustomTextStyle.headingStyle().copyWith(
            color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Alarm Name',
                hintText: 'Enter alarm name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
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
            onPressed: () => Navigator.of(ctx).pop(),
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
              SharedPreferences prefs = await SharedPreferences.getInstance();

              // Update values
              alarms[index]['alarm_name'] = nameController.text;
              alarms[index]['alarm_description'] = descController.text;

              // Save to SharedPreferences
              List<String> updatedAlarms =
              alarms.map((e) => jsonEncode(e)).toList();
              await prefs.setStringList('alarms', updatedAlarms);

              setState(() {});
              Navigator.of(ctx).pop();
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
      appBar: CustomAppbar(title: "Location Based Alarms"),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
              : alarms.isEmpty
              ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/empty-box.png",height: 100,),
              SizedBox(height: 10,),
              Text("No alarm found ",style: CustomTextStyle.subtitleStyle(),),
            ],
          ))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  final days = (alarm['alarm_days'] as List?)?.join(', ') ?? "";
                  return Stack(
                    children: [
                      InkWell(
                        // onLongPress: () {
                        // _confirmDelete(index);
                        // },
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => LocationbasedAlarmdetails(alarm: alarm),
                          ));
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
                                Icon(Icons.alarm, size: 60, color: kPrimaryColor),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildRowTitleValue(
                                        context,
                                        "Alarm Name: ",
                                        alarm['alarm_name'],
                                      ),
                                      const SizedBox(height: 3),

                                      _buildRowTitleValue(
                                        context,
                                        "Destination: ",
                                        alarm['alarm_description'],
                                      ),
                                      const SizedBox(height: 3),
                                      _buildRowTitleValue(
                                        context,
                                        "Location: ",
                                        alarm['location_name'],
                                      ),
                                      const SizedBox(height: 3),
                                      _buildRowTitleValue(
                                          context,
                                          "Days: ","$days", maxLines: 2),
                                      const SizedBox(height: 3),

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
                          onTap: () {
                            _markFavorite(index);
                          },

                          child: CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.4),
                            radius: 18,
                            child: Icon(
                              alarm['is_favorite'] == true
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
    );
  }
}

Widget _buildRowTitleValue(BuildContext context,String title, String value, {int maxLines = 1}) {
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
            color: Theme.of(context).brightness == Brightness.dark
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
