import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/constants.dart';
import '../widgets/CustomButton_Blue.dart';
import '../widgets/custom_appBar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/toast.dart';


class UpdatePasswordScreen extends StatefulWidget {
  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
  TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;


  Future<void> updatePassword() async {
    setState(() {
      isLoading = true;
    });

    String currentPassword = currentPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      showtoast("Please fill all fields!", true);
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user == null) {
        showtoast("No user is signed in.", true);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Use the current user's email for reauthentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      showtoast("Password updated successfully!", false);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print("Firebase Error Code: ${e.code}");

      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found.";
          break;
        case 'wrong-password':
          errorMessage = "Current password is incorrect.";
          break;
        case 'weak-password':
          errorMessage = "New password is too weak. Use at least 6 characters.";
          break;
        case 'requires-recent-login':
          errorMessage = "Please log in again before changing the password.";
          break;
        case 'invalid-credential':
          errorMessage = "The authentication credential is incorrect or has expired.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many requests. Try again later.";
          break;
        default:
          errorMessage = "Unexpected error: ${e.code}";
      }

      showtoast(errorMessage, true);
    } catch (e) {
      showtoast("Something went wrong: $e", true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  void showtoast(String message, bool isError) {
    Utils().toastmessage(message: message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(

        title: 'Update Password',
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined, color: kPrimaryColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Your Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'To update your password, please enter your email, current password, and a new password.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              CustomTextField(
                controller: emailController,
                hintText: 'Enter your email address here...',
                labelText: 'Email',
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: currentPasswordController,
                hintText: 'Enter your current password...',
                labelText: 'Current Password',
                isPassword: true,
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: newPasswordController,
                hintText: 'Enter your new password...',
                labelText: 'New Password',
                isPassword: true,
              ),
              SizedBox(height: 20),
              Text(
                'Note: Your new password should be at least 8 characters long.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 20.h),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : CustomButton_Blue(
                text: 'Change Password',
                onTap: updatePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
