import 'dart:io';
import 'package:alarm_fyp/view/createAccount/email_verificationView.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../models/create_account_models/basic_info_user.dart';
import '../../services/geominder_apis.dart';
import '../../utils/Primary_text.dart';
import '../../utils/assets.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../../widgets/CustomButton_Blue.dart';
import '../../widgets/custom_appBar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/toast.dart';

class BasicinfoView extends StatefulWidget {
  BasicinfoView({super.key});

  @override
  State<BasicinfoView> createState() => _BasicinfoViewState();
}

class _BasicinfoViewState extends State<BasicinfoView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();


  bool _isLoading = false;
  String? fullnameError;
  String? emailError;
  String? addressError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  File? image;
  final _picker = ImagePicker();

  void showPictureDialog(BuildContext context, ImagePicker picker) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kdialogColor,
          title: Row(
            children: [
              Text(
                'Choose Profile Photo',
                style: CustomTextStyle.headingStyle(
                  color: kPrimaryColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close, color: kPrimaryColor, size: 25),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                onPressed: () async {
                  Navigator.pop(context);
                  final pickFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (pickFile != null) {
                    image = File(pickFile.path);
                    setState(() {});
                  } else {
                    Utils().toastmessage(
                      message: "Sorry, unable to pick image from camera",
                      isError: true,
                    );
                    debugPrint("Sorry, unable to pick image from camera.");
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined, color: kiconColor),
                label: Text(
                  'Camera',
                  style: CustomTextStyle.GeneralStyle(color: kiconColor),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                onPressed: () async {
                  Navigator.pop(context);
                  final pickFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (pickFile != null) {
                    image = File(pickFile.path);
                    setState(() {});
                  } else {
                    debugPrint("Sorry, unable to pick image from gallery.");
                  }
                },
                icon: const Icon(Icons.image, color: kiconColor),
                label: Text(
                  'Gallery',
                  style: CustomTextStyle.GeneralStyle(color: kiconColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> uploadProfilePicture(File imageFile, String uid) async {
    try {
      var url = Uri.parse('${Constants.upload_profilepic_api}');

      var request = http.MultipartRequest('POST', url);
      request.fields['uid'] = uid;

      List<int> imageBytes = await imageFile.readAsBytes();
      String imageName = imageFile.path.split('/').last; // Extract image name

      request.files.add(
        http.MultipartFile.fromBytes(
          'picture',
          imageBytes,
          filename: imageName,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Upload successful: $responseBody');
        Utils().toastmessage(
          message: "Profile picture uploaded successfully.",
          isError: false,
        );
        return imageName; // Return the image name
      } else {
        print('Upload failed with status: ${response.statusCode}');
        Utils().toastmessage(message: "Upload failed.", isError: true);
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      Utils().toastmessage(message: "Error uploading image.", isError: true);
      return null;
    }
  }

  void _signUp() async {
    setState(() => _isLoading = true);

    // Field validation
    setState(() {
      fullnameError =
          fullnameController.text.trim().isEmpty
              ? "Full name is required"
              : null;
      addressError =
          addressController.text.trim().isEmpty ? "Address is required" : null;
      emailError =
          emailController.text.trim().isEmpty ? "Email is required" : null;
      phoneError =
          phoneController.text.trim().isEmpty
              ? "Phone number is required"
              : null;
      passwordError =
          passwordController.text.trim().isEmpty
              ? "Password is required"
              : null;
      confirmPasswordError =
          confirmPasswordController.text.trim().isEmpty
              ? "Confirm Password is required"
              : null;
    });

    if ([
      emailError,
      phoneError,
      passwordError,
      confirmPasswordError,
    ].any((e) => e != null)) {
      setState(() => _isLoading = false);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        confirmPasswordError = "Passwords do not match";
        _isLoading = false;
      });
      return;
    }



    if (image == null) {
      Utils().toastmessage(
        message: 'Must Select Profile Picture',
        isError: true,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        // Upload profile picture and get the image name
        String? imageName = await uploadProfilePicture(image!, user.uid);

        UserBasicDetailsModel newUser = UserBasicDetailsModel(
          uid: user.uid,
          name: fullnameController.text.trim(),
          email: emailController.text.trim(),
          address: addressController.text.trim(),
          phone: phoneController.text.trim(),
          profilePicture: imageName ?? "default.png", // Assign image name here
        );

        await _database.child("users").child(user.uid).set(newUser.toJson());

        Utils().toastmessage(
          message:
              'Sign Up Successfully and Verification email sent! Please check your inbox.',
          isError: false,
        );

        await user.sendEmailVerification();

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>EmailVerificationview()));

      }
    } on FirebaseAuthException catch (e) {
      print("TRTRTRT  = ${e.toString()}");
      // Handle specific Firebase Auth errors
      String errorMessage = "Something went wrong, Please try again later!";

      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use!";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address!";
      } else if (e.code == 'weak-password') {
        errorMessage = "Your password is too weak!";
      }

      Utils().toastmessage(message: errorMessage, isError: true);
    } catch (e) {
      Utils().toastmessage(
        message: 'Something went wrong, Please try again later!',
        isError: true,
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Create New Account',
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 7,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimaryColor, width: 3.0),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundImage:
                                  image == null
                                      ? const AssetImage(
                                        'assets/user.png',
                                      )
                                      : FileImage(File(image!.path))
                                          as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  showPictureDialog(context, _picker);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: kPrimaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    color: kPrimaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomTextField(
                      controller: fullnameController,
                      hintText: 'Enter your full name...',
                      labelText: 'Full Name',
                      errorText: fullnameError,
                    ),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Enter your email address...',
                      labelText: 'Email Address',
                      errorText: emailError,
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      hintText: 'Enter your Phone Number...',
                      labelText: 'Phone Number',
                      errorText: phoneError,
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      controller: addressController,
                      hintText: 'Enter your complete address...',
                      labelText: 'Complete Address',
                      errorText: addressError,
                    ),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Enter your Password...',
                      labelText: 'Password',
                      isPassword: true,
                      errorText: passwordError,
                    ),
                    CustomTextField(
                      controller: confirmPasswordController,
                      hintText: 'Enter your Password again...',
                      labelText: 'Confirm Password',
                      isPassword: true,
                      errorText: confirmPasswordError,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      )
                      : CustomButton_Blue(
                        text: 'Create Account',
                        onTap: () {
                          _signUp();
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
