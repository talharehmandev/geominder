import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/Primary_text.dart';
import '../utils/constants.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingSize;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final bool showLeading;

  CustomAppbar({
    required this.title,
    this.actions,
    this.leading,
    this.leadingSize,
    this.leadingPadding,
    this.actionsPadding,
    this.showLeading = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Prevents automatic leading widget
      centerTitle: false,
      shadowColor: Colors.black,
      elevation: 3,
      title: Padding(
        padding: showLeading
            ? EdgeInsets.zero // No extra padding if leading is shown
            : const EdgeInsets.only(left: 16.0), // Add padding when leading is hidden
        child: Text(
          title,
          style: CustomTextStyle.headingStyle(fontSize: 21.sp, color: kPrimaryColor,fontWeight: FontWeight.bold),
        ),
      ),
      // leading: showLeading
      //     ? (leading != null
      //     ? Padding(
      //   padding: leadingPadding ?? EdgeInsets.all(8.0), // Default padding
      //   child: SizedBox(
      //     width: leadingSize ?? 20.0, // Default size
      //     height: leadingSize ?? 20.0,
      //     child: leading,
      //   ),
      // )
      //     : null)
      //     : null, // No leading widget when showLeading is false
      leading: showLeading
          ? (leading != null
          ? Padding(
        padding: leadingPadding ?? EdgeInsets.all(8.0),
        child: SizedBox(
          width: leadingSize ?? 20.0,
          height: leadingSize ?? 20.0,
          child: leading,
        ),
      )
          : Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: kPrimaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ))
          : null,


      actions: actions
          ?.map((action) => Padding(
        padding: actionsPadding ?? EdgeInsets.symmetric(horizontal: 8.0), // Default padding
        child: action,
      ))
          .toList(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
