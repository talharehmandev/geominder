// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import '../utils/constants.dart';
// import '../utils/Primary_text.dart';
//
// class CustomTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final String labelText;
//   final TextInputType keyboardType;
//   final String? errorText;
//   final int? maxLines;
//   final bool isPassword;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//
//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     required this.labelText,
//     this.keyboardType = TextInputType.text,
//     this.errorText,
//     this.maxLines = 1,
//     this.isPassword = false,
//     this.prefixIcon,
//     this.suffixIcon,
//   }) : super(key: key);
//
//   @override
//   _CustomTextFieldState createState() => _CustomTextFieldState();
// }
//
// class _CustomTextFieldState extends State<CustomTextField> {
//   bool _isPasswordHidden = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       enableSuggestions: false,
//       autofillHints: [],
//       controller: widget.controller,
//       keyboardType: widget.keyboardType,
//       style: TextStyle(color: Colors.grey),
//       maxLines: widget.isPassword ? 1 : widget.maxLines,
//       obscureText: widget.isPassword ? _isPasswordHidden : false,
//       decoration: InputDecoration(
//         fillColor: Colors.white,
//         filled: true,
//         hintStyle: CustomTextStyle.GeneralStyle(color: Colors.grey),
//         hintText: widget.hintText,
//         labelText: widget.labelText,
//         labelStyle: CustomTextStyle.GeneralStyle(
//           color: kTextBlackColor,
//           fontWeight: FontWeight.w600,
//         ),
//         alignLabelWithHint: true,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.grey),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.grey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
//         ),
//         prefixIcon: widget.prefixIcon,
//         suffixIcon: widget.isPassword
//             ? PasswordToggleIcon(
//           isPasswordHidden: _isPasswordHidden,
//           onToggle: () {
//             setState(() {
//               _isPasswordHidden = !_isPasswordHidden;
//             });
//           },
//         )
//             : widget.suffixIcon,
//         errorText: widget.errorText, // Display error inside InputDecoration
//       ),
//     );
//   }
// }
//
// class PasswordToggleIcon extends StatelessWidget {
//   final bool isPasswordHidden;
//   final VoidCallback onToggle;
//
//   const PasswordToggleIcon({
//     Key? key,
//     required this.isPasswordHidden,
//     required this.onToggle,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Icon(
//         isPasswordHidden ? Icons.visibility : Icons.visibility_off,
//         color: Colors.grey,
//       ),
//       onPressed: onToggle,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/constants.dart';
import '../utils/Primary_text.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final String? errorText;
  final int? maxLines;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.maxLines = 1,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      enableSuggestions: false,
      autofillHints: [],
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      obscureText: widget.isPassword ? _isPasswordHidden : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.white,
        hintStyle: TextStyle(color: theme.hintColor),
        hintText: widget.hintText,
        labelText: widget.labelText,
        labelStyle: CustomTextStyle.GeneralStyle(
          color: theme.textTheme.bodyLarge?.color ?? kTextBlackColor,
          fontWeight: FontWeight.w600,
        ),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? PasswordToggleIcon(
          isPasswordHidden: _isPasswordHidden,
          onToggle: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
        )
            : widget.suffixIcon,
        errorText: widget.errorText,
      ),
    );
  }
}

class PasswordToggleIcon extends StatelessWidget {
  final bool isPasswordHidden;
  final VoidCallback onToggle;

  const PasswordToggleIcon({
    Key? key,
    required this.isPasswordHidden,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    return IconButton(
      icon: Icon(
        isPasswordHidden ? Icons.visibility : Icons.visibility_off,
        color: iconColor,
      ),
      onPressed: onToggle,
    );
  }
}

