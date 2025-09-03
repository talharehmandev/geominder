import 'package:alarm_fyp/view/bin_alarms/task_alarm_bin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/common_drawer.dart';
import '../../../widgets/custom_appBar.dart';
import '../../utils/constants.dart';
import 'Location_Alarm_Bin.dart';


class alarmBintabBar extends StatelessWidget {
  const alarmBintabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        drawer: Common_Drawer(),
        appBar: CustomAppbar(title: "Alarm Bin",leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: kPrimaryColor,))),
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
                  children: <Widget>[taskBin(),locationbin()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
