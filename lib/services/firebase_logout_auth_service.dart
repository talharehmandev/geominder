import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/loginView.dart';
import '../widgets/toast.dart';

Future<void> logoutUser(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Loginview()),
          (Route<dynamic> route) => false, // Remove all previous routes
    );
  } catch (e) {
    debugPrint("Logout failed: $e");
    Utils().toastmessage(message: "Logout failed. Try again.", isError: true);
  }
}
