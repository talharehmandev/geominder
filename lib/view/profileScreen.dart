import 'dart:async';
import 'package:alarm_fyp/services/geominder_apis.dart';
import 'package:alarm_fyp/view/updatePassword.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'editProfile.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  late DatabaseReference userRef;
  StreamSubscription<DatabaseEvent>? _userSubscription;

  @override
  void initState() {
    super.initState();
    startListeningToUserData();
  }

  void startListeningToUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      userRef = FirebaseDatabase.instance.ref('users/$uid');
      _userSubscription = userRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            userData = Map<String, dynamic>.from(data as Map);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppbar(
        title: 'Profile',
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined, color: kPrimaryColor),
        ),
        actions: [
          IconButton(
            onPressed: ()  {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(userData: userData!),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: kPrimaryColor),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout, color: kPrimaryColor),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: Image.network('${Constants.profileUrl}/${userData!['profile_picture']}'),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      '${Constants.profileUrl}/${userData!['profile_picture']}',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userData!['name'] ?? '',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              userData!['email'] ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      value: userData!['phone'] ?? '',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: userData!['email'] ?? '',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: userData!['address'] ?? '',
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePasswordScreen(),));
              },
              child: const Text('Change Password?',style: TextStyle(color: kTextWhiteColor),),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,

              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          child: Icon(icon, color: kPrimaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}
