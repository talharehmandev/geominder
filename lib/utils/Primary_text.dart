import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'constants.dart';

class CustomTextStyle {
  static const String fontFamily = 'RobotoBlackItalic';
  // Heading style
  static TextStyle headingStyle({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color color = kTextBlackColor,
    double letterSpacing = 0.0,
    bool underline = false,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? 21.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: underline ? TextDecoration.underline : null,
      decorationThickness: underline ? 2 : null,
      decorationColor: underline ? Colors.white : null,
    );
  }

  // General text style
  static TextStyle GeneralStyle({
    double? fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = kTextBlackColor,
    double letterSpacing = 0.0,
    bool underline = false,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? 18.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: underline ? TextDecoration.underline : null,
      decorationThickness: underline ? 2 : null,
      decorationColor: underline ? Colors.white : null,
    );
  }

  // Subtitle style
  static TextStyle subtitleStyle({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color color = kTextLightColor,
    double letterSpacing = 0.2,
    bool italic = false,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? 18.sp,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }
}
