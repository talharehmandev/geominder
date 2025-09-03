import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/common_drawer.dart';
import '../../../widgets/custom_appBar.dart';
import '../../utils/constants.dart';
import 'fav_task_alarms.dart';
import 'favourit_Locationalarms.dart';

class favouritTabBar extends StatelessWidget {
  const favouritTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        drawer: Common_Drawer(),
        appBar: CustomAppbar(title: "Favourite Alarms"),
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                labelColor: kPrimaryColor,
                indicatorColor: kPrimaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: <Widget>[
                  Tab(
                    child: Text(
                      'Task Alarms',
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Location Alarms',
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[FavTaskAlarms(), favouritLocation_AlarmList()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
