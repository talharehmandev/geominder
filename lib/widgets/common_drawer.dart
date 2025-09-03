import 'package:alarm_fyp/services/geominder_apis.dart';
import 'package:alarm_fyp/view/NavigationView.dart';
import 'package:alarm_fyp/view/profileScreen.dart';
import 'package:alarm_fyp/widgets/profileView_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import '../providers/userdata_provider.dart';
import '../services/firebase_logout_auth_service.dart';
import '../utils/Primary_text.dart';
import '../utils/constants.dart';
import '../view/bin_alarms/binAlarms_tabbar.dart';
import '../view/settingsView.dart';

class Common_Drawer extends StatelessWidget {
  const Common_Drawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Drawer(
      width: 75.w,
      //backgroundColor: kdialogColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimaryColor, width: 2),
                  ),
                  child: InkWell(
                    onTap: () {
                      showFullScreenImage(context,  '${Constants.profileUrl}/${userProvider.user!.profilePicture}',);
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.network(
                          '${Constants.profileUrl}/${userProvider.user!.profilePicture}', // your network image URL
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.error,
                            ); // shows error icon if image fails to load
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  "${userProvider.user!.name}",
                  style: CustomTextStyle.headingStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ).copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "${userProvider.user!.email}",
                  style: CustomTextStyle.subtitleStyle(fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  icon: Icons.account_circle_rounded,
                  title: "Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.navigation,
                  title: "Navigation's",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RouteMap()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.delete,
                  title: "Bin",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => alarmBintabBar()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.share,
                  title: "Share",
                  onTap: () async {
                    final String message =
                        'Download our app and manage your daily tasks with geominder.';

                    await Share.share(message);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () async {
                    await logoutUser(context);
                  },
                ),
              ],
            ),
          ),

          Divider(color: kToastColor, thickness: 0.6),

          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              '© 2025 Geominder',
              style: CustomTextStyle.subtitleStyle(
                color: Colors.grey.shade500,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(
        title,
        style: CustomTextStyle.subtitleStyle(
          fontSize: 16.5.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(Icons.navigate_next),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: kPrimaryColor.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
