import 'dart:io';

import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/widgets/CustomButton_Blue.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LocationbasedAlarmdetails extends StatefulWidget {
  final Map<String, dynamic> alarm;

  const LocationbasedAlarmdetails({super.key, required this.alarm});

  @override
  State<LocationbasedAlarmdetails> createState() =>
      _LocationbasedAlarmdetailsState();
}

class _LocationbasedAlarmdetailsState extends State<LocationbasedAlarmdetails> {
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
    print(  widget.alarm['longitude'].toString(),);
    return Scaffold(
      appBar: CustomAppbar(
        title: "Alarm Details",
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_outlined, color: kPrimaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.alarm,
                    label: 'Alarm Name',
                    value: widget.alarm['alarm_name'] ?? 'N/A',
                  ),
                  Divider(thickness: 1.2, height: 3.h),
                  _buildDetailColumn(
                    icon: Icons.location_on,
                    label: 'Description',
                    value:
                        widget.alarm['alarm_description'] ??
                        'No description provided',
                  ),
                  Divider(thickness: 1.2, height: 3.h),
                  _buildDetailRow(
                    icon: Icons.circle,
                    label: 'Area Radius',
                    value: '${widget.alarm['alarm_radius']} meters',
                  ),
                  Divider(thickness: 1.2, height: 3.h),
                  _buildDetailRow(
                    icon: Icons.place,
                    label: 'Alarm Location',
                    value: widget.alarm['location_name'] ?? 'Not specified',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kPrimaryColor),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: CustomTextStyle.subtitleStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(value, style: CustomTextStyle.headingStyle(fontSize: 17.sp).copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: kErrorColor),
            SizedBox(width: 3.w),
            Text(
              '$label:',
              style: CustomTextStyle.subtitleStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: CustomTextStyle.headingStyle(fontSize: 18.sp).copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          maxLines: 9,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
