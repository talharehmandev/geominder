import 'dart:io';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/widgets/CustomButton_Blue.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../models/taskModel.dart';
import '../../widgets/profileView_widgets.dart'; // This should contain TaskAlarm class

class ViewMytaskDetails extends StatefulWidget {
  final TaskAlarm alarm; // 👈 Must be TaskAlarm

  const ViewMytaskDetails({super.key, required this.alarm});

  @override
  State<ViewMytaskDetails> createState() => _ViewMytaskDetailsState();
}

class _ViewMytaskDetailsState extends State<ViewMytaskDetails> {
  String selectedMode = "bicycling";

  void _startNavigationWithIntent(
    String destinationLatreq,
    String destinationlngreq,
  ) {
    final destinationLat = destinationLatreq;
    final destinationLng = destinationlngreq;

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data:
            'google.navigation:q=$destinationLat,$destinationLng&mode=$selectedMode',
        package: 'com.google.android.apps.maps',
      );
      intent.launch().catchError((e) {
        print('Error launching Google Maps: $e');
      });
    } else {
      print("This method works only on Android.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: '${widget.alarm.name}',
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined, color: kPrimaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.alarm.imagePath != null)
                InkWell(
                  onTap: () {
                    final file = File(
                      widget.alarm.imagePath!,
                    ); // Convert String to File
                    showFullScreenImage(context, file, type: ImageType.file);
                  },
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.alarm.imagePath!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_sharp,
                                  color: kErrorColor,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Location: ',
                                  style: CustomTextStyle.subtitleStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.alarm.location,
                              style: CustomTextStyle.headingStyle().copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.watch_later, color: kPrimaryColor),
                            SizedBox(width: 5),
                            Text(
                              'Time: ',
                              style: CustomTextStyle.subtitleStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.alarm.time,
                              style: CustomTextStyle.headingStyle().copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.description, color: kPrimaryColor),
                            SizedBox(width: 5),
                            Text(
                              'Description: ',
                              style: CustomTextStyle.subtitleStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.alarm.description,
                          style: CustomTextStyle.headingStyle(
                            fontSize: 17.sp,
                          ).copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: kPrimaryColor),
                            SizedBox(width: 5),
                            Text(
                              'Repeating Days: ',
                              style: CustomTextStyle.subtitleStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children:
                              widget.alarm.days
                                  .map(
                                    (day) => Chip(
                                      label: Text(day),
                                      backgroundColor: Colors.blue[100],
                                      labelStyle: TextStyle(
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomButton_Blue(
        text: 'Navigate Towards Location',
        onTap: () {
          _startNavigationWithIntent(widget.alarm.lat, widget.alarm.long);
        },
        width: 55.w,
      ),
    );
  }
}
