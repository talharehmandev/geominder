import 'dart:convert';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/widgets/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appBar.dart';
import '../location_based_alarm_module/locationBased_alarmDetails.dart';

class favouritLocation_AlarmList extends StatefulWidget {
  const favouritLocation_AlarmList({super.key});

  @override
  State<favouritLocation_AlarmList> createState() => _favouritLocation_AlarmListState();
}

class _favouritLocation_AlarmListState extends State<favouritLocation_AlarmList> {
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
      alarms = storedAlarms
          .map((alarmJson) => jsonDecode(alarmJson) as Map<String, dynamic>)
          .where((alarm) => alarm['is_favorite'] == true) // <-- Only favorites
          .toList();
      isLoading = false;
    });
  }

  Future<void> _markFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Find the correct alarm in all stored alarms
    List<String> storedAlarms = prefs.getStringList('alarms') ?? [];
    List<Map<String, dynamic>> allAlarms = storedAlarms
        .map((alarmJson) => jsonDecode(alarmJson) as Map<String, dynamic>)
        .toList();

    // Find the matching alarm by location_name (or alarm_name, depending what is unique)
    String locationName = alarms[index]['location_name'];

    int realIndex = allAlarms.indexWhere((alarm) => alarm['location_name'] == locationName);

    if (realIndex != -1) {
      allAlarms[realIndex]['is_favorite'] = !(allAlarms[realIndex]['is_favorite'] == true);
      List<String> updatedAlarms = allAlarms.map((alarm) => jsonEncode(alarm)).toList();
      await prefs.setStringList('alarms', updatedAlarms);
    }

    _loadAlarmData(); // <-- Reload and filter again
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
          child: CircularProgressIndicator(
            color: kPrimaryColor,
          ))
          : alarms.isEmpty
          ?Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/empty-box.png",height: 100,),
          SizedBox(height: 10,),
          Text("No Alarm found ",style: CustomTextStyle.subtitleStyle(),),
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
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => LocationbasedAlarmdetails(alarm: alarm,),
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

