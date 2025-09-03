import 'package:alarm_fyp/view/favouritAlarm/FavouritTabBar.dart';
import 'package:alarm_fyp/view/task_based_alarm_module/Taskbased_alarmsList.dart';
import 'package:alarm_fyp/view/location_based_alarm_module/locartionbased_alarm_list.dart';
import 'package:alarm_fyp/view/favouritAlarm/favourit_Locationalarms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/constants.dart';
import '../widgets/internet_checker_widget.dart';
import 'home.dart';
import 'location_based_alarm_module/create_locationAlarm.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static List<Widget> _widgetOptions = <Widget>[
    const Home(),
    Location_basedAlarmList(),
    Mytask(),
    favouritTabBar(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InternetChecker(
      child: Scaffold(
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        // bottomNavigationBar: BottomNavigationBar(
        //   backgroundColor: kdialogColor,
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       activeIcon: Icon(Icons.home),
        //       icon: Icon(Icons.home_filled),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       activeIcon: Icon(Icons.access_alarms_rounded),
        //       icon: Icon(Icons.alarm_add_outlined),
        //       label: 'Location Alarms',
        //     ),
        //     BottomNavigationBarItem(
        //       activeIcon: Icon(Icons.task_alt),
        //       icon: Icon(Icons.add_task),
        //       label: 'Tasks',
        //     ),
        //     BottomNavigationBarItem(
        //       activeIcon: Icon(Icons.favorite),
        //       icon: Icon(Icons.favorite_border),
        //       label: 'Favorite Alarms',
        //     ),
        //   ],
        //   currentIndex: _selectedIndex,
        //   selectedItemColor: kPrimaryColor,
        //   // Selected item color
        //   unselectedItemColor: Color(0xFF686868),
        //
        //   // Unselected item color
        //   onTap: _onItemTapped,
        // ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Ensure background color shows
          backgroundColor: kPrimaryColor, // Your custom background color
          selectedItemColor: kTextWhiteColor,
          unselectedItemColor: kTextBlackColor,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.home),
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.access_alarms_rounded),
              icon: Icon(Icons.alarm_add_outlined),
              label: 'Alarms',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.task_alt),
              icon: Icon(Icons.add_task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.favorite),
              icon: Icon(Icons.favorite_border),
              label: 'Favorite',
            ),
          ],
        ),

      ),
    );
  }
}
