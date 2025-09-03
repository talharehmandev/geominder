import 'dart:async';
import 'package:alarm_fyp/view/loginView.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/Primary_text.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_appBar.dart';

class EmailVerificationview extends StatefulWidget {
  const EmailVerificationview({ super.key});

  @override
  State<EmailVerificationview> createState() => _EmailVerificationviewState();
}

class _EmailVerificationviewState extends State<EmailVerificationview> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isEmailVerified = false;
  Timer? _timer;

  Future<void> _checkEmailVerified(Timer timer) async {
    await _auth.currentUser?.reload();
    _user = _auth.currentUser;
    if (_user?.emailVerified ?? false) {
      setState(() {
        _isEmailVerified = true;
      });
      timer.cancel();
      await Future.delayed(Duration(seconds: 3)); // wait for 2 seconds
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginview()),
      );
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), _checkEmailVerified);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Email Verification',
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined, color: kPrimaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Spacer(),
            Center(
              child:
                  _isEmailVerified
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 55),
                          SizedBox(height: 10),
                          Text(
                            "Your email is verified!",
                            style: CustomTextStyle.headingStyle(),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          Icon(Icons.email, color: kPrimaryColor, size: 55),
                          SizedBox(height: 10),
                          Text(
                            "Check inbox to verify.",
                            style: CustomTextStyle.headingStyle(),
                          ),
                        ],
                      ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
