import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/forgot_passowrd.dart';
import '../utils/constants.dart';
import '../widgets/customButton_white.dart';
import '../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String id = 'reset_password';
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  static final auth = FirebaseAuth.instance;
  bool _isLoading = false; // Added to track loading state

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return AuthStatus.userNotFound;
      } else {
        return AuthExceptionHandler.handleAuthException(e);
      }
    } catch (e) {
      return AuthStatus.unknown;
    }
  }

  void _handleRecoverPassword() async {
    if (_key.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      final _status = await resetPassword(email: _emailController.text.trim());

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      String message;
      Color backgroundColor;

      switch (_status) {
        case AuthStatus.successful:
          message = "Password reset email sent successfully!";
          backgroundColor = Colors.green;
          break;
        case AuthStatus.userNotFound:
          message = "No account found with this email.";
          backgroundColor = Colors.red;
          break;
        default:
          message = "An error occurred. Please try again.";
          backgroundColor = Colors.red;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 50.0, bottom: 25.0),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
                const SizedBox(height: 70),
                const Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please enter your email address to recover your password.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Email address',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: _emailController, hintText: "Enter your email here...", labelText: 'Email'),
                const SizedBox(height: 2),
                const Expanded(child: SizedBox()),

                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kPrimaryColor,)) // Show loading indicator
                    : CustomButton_White(text: 'Recover Password', onTap: _handleRecoverPassword),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
