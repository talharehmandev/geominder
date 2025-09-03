import 'dart:io';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:alarm_fyp/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../services/geominder_apis.dart';
import '../utils/Primary_text.dart';
import '../utils/constants.dart';
import '../widgets/toast.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _addressController = TextEditingController(text: widget.userData['address']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      String? uploadedImageName;

      // Upload image if user selected a new one
      if (image != null) {
        uploadedImageName = await uploadProfilePicture(image!, uid);
      }

      // Prepare data to update
      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };

      // Include image name if uploaded
      if (uploadedImageName != null) {
        updatedData['profile_picture'] = uploadedImageName;
      }

      // Update Firebase Database
      await FirebaseDatabase.instance.ref('users/$uid').update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined, color: kPrimaryColor),
        ),
        title: 'Edit Profile',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 10,),
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
                        backgroundImage: image == null
                            ? (widget.userData['profile_picture'] != null
                            ? NetworkImage('${Constants.profileUrl}/${widget.userData['profile_picture']}')
                            : const AssetImage('assets/user.png')) as ImageProvider
                            : FileImage(image!)
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
              SizedBox(height: 10,),
              CustomTextField(controller: _nameController, hintText: 'Enter new name here', labelText: 'Name'),
              const SizedBox(height: 16),
              CustomTextField(controller: _phoneController, hintText: 'Enter new name here', labelText: 'Phone Number'),
              const SizedBox(height: 16),
              CustomTextField(controller: _addressController, hintText: 'Enter new Address', labelText: 'Address'),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
