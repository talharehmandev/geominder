import 'package:alarm_fyp/view/bottom_bar.dart';
import 'package:alarm_fyp/view/createAccount/BasicinfoView.dart';
import 'package:alarm_fyp/view/resetPasswordView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../models/user_data_model.dart';
import '../providers/userdata_provider.dart';
import '../utils/Primary_text.dart';
import '../utils/constants.dart';
import '../widgets/customButton_blue.dart';
import '../widgets/customButton_white.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/internet_checker_widget.dart';
import '../widgets/toast.dart';

class Loginview extends StatefulWidget {
  Loginview({super.key});

  @override
  State<Loginview> createState() => _LoginviewState();
}

class _LoginviewState extends State<Loginview> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  bool isLoading = false;
  String? emailError;
  String? passwordError;
  bool _isChecked = false;

  Future<void> loginUser() async {
    setState(() {
      emailError =
          emailController.text.trim().isEmpty ? "Email is required" : null;
      passwordError =
          passwordController.text.trim().isEmpty
              ? "Password is required"
              : null;
    });

    if (emailError != null || passwordError != null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        if (_isChecked != true) {
          await FirebaseAuth.instance.signOut();
        }

        DatabaseReference userRef = _database
            .ref()
            .child("users")
            .child(user.uid);
        DatabaseEvent event = await userRef.once(); // Await the database fetch

        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> userData =
              event.snapshot.value as Map<dynamic, dynamic>;
          UserModel userModel = UserModel.fromMap(userData);

          // Store user data in Provider
          Provider.of<UserProvider>(context, listen: false).setUser(userModel);

          setState(() {
            isLoading = false; // Hide loader before navigating
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavBar()),
          );
        }
        //cant save firebase auth for autologin
      }
    } on FirebaseAuthException catch (e) {
      Utils().toastmessage(
        message: 'Invalid email or password! Login Failed',
        isError: true,
      );
      print(e.message);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InternetChecker(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/alarmlogo.png",
                      height: 130,
                      width: 200,
                    ),
                  ),
                  Text(
                    "Login to go next ...",
                    style: CustomTextStyle.GeneralStyle(fontSize: 21.sp,fontWeight: FontWeight.bold).copyWith(
                      color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Enter your email address...',
                    labelText: 'Email',

                    keyboardType: TextInputType.emailAddress,
                    errorText: emailError, // Pass null if no error
                  ),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                    labelText: 'Password',

                    errorText: passwordError,
                    // Pass null if no error
                    isPassword: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(),));
                        },
                        child: Text(
                          "Forgot Password?",
                          style: CustomTextStyle.GeneralStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      Checkbox(
                        activeColor: kPrimaryColor,
                        value: _isChecked, // Current state of the checkbox
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false; // Update the state
                          });
                        },
                      ),
                      Text(
                        "Remember me",
                        style: CustomTextStyle.GeneralStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  isLoading
                      ? CircularProgressIndicator(color: kPrimaryColor)
                      : CustomButton_Blue(text: "Login", onTap: loginUser),
                  Spacer(),
                  Text("Don't have an account? Than SignUp to go next",style: CustomTextStyle.subtitleStyle(fontSize: 16.sp,fontWeight: FontWeight.bold),),
                  //Spacer(),
                  CustomButton_White(
                    text: 'Sign Up',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BasicinfoView(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
