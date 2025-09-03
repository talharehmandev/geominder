import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../utils/Primary_text.dart';
import '../utils/constants.dart';

class CustomButton_White extends StatelessWidget {
  final String text; // Button text
  final VoidCallback onTap; // Functionality when button is tapped

  const CustomButton_White({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w, // Set the width to 100% of the screen width
      child: ElevatedButton(
        onPressed: onTap, // Call the provided onTap function
        style: ElevatedButton.styleFrom(
          backgroundColor: kwhiteColorbutton, // Button background color
          foregroundColor: kTextBlackColor, // Text color
          textStyle: CustomTextStyle.headingStyle(fontSize: 16, fontWeight: FontWeight.bold), // Text styling
          padding: EdgeInsets.symmetric(vertical: 12), // Padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Rounded corners
          ),
        ),
        child: Text(text, textAlign: TextAlign.center,style: TextStyle(color: kPrimaryColor),),
      ),
    );
  }
}
