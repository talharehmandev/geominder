import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/Primary_text.dart';
import '../utils/constants.dart';

class CustomButton_Blue extends StatelessWidget {
  final String text; // Button text
  final VoidCallback onTap; // Functionality when button is tapped
  final double? width; // Optional width parameter

  const CustomButton_Blue({
    Key? key,
    required this.text,
    required this.onTap,
    this.width, // Optional width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 100.w,
      height: 40,// Use provided width or default to 100% screen width
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: kTextWhiteColor,
          textStyle: CustomTextStyle.headingStyle(fontSize: 16, fontWeight: FontWeight.bold),
          padding: EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: Text(text,style: CustomTextStyle.GeneralStyle(color: kTextWhiteColor,fontWeight: FontWeight.bold,fontSize: 17.sp), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
