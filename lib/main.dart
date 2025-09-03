import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm_fyp/providers/alarmSound_Provider.dart';
import 'package:alarm_fyp/providers/internet_check_provider.dart';
import 'package:alarm_fyp/providers/theme_change_provider.dart';
import 'package:alarm_fyp/providers/userdata_provider.dart';
import 'package:alarm_fyp/providers/vibration_provider.dart';
import 'package:alarm_fyp/services/alarmFun.dart';
import 'package:alarm_fyp/services/firebase_options.dart';
import 'package:alarm_fyp/utils/NotificationHandler.dart';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/view/task_based_alarm_module/Taskbased_alarmsList.dart';
import 'package:alarm_fyp/view/bottom_bar.dart';
import 'package:alarm_fyp/view/loginView.dart';
import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'models/taskModel.dart';
import 'models/user_data_model.dart';



String alarmPath = "";
void main() async {
  FlutterForegroundTask.initCommunicationPort();
  WidgetsFlutterBinding.ensureInitialized();
  initNotifications(); // Add
  await Alarm.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Alarm.ringStream.stream.listen((alarmSettings) async {
    print('⏰ Alarm is ringing for ID: ${alarmSettings.id}');
    // You can navigate to another page if needed
    const MethodChannel _channel = MethodChannel('com.example.alarm_fyp/launch');
    await _channel.invokeMethod('launchApp');
  });
  // setupAlarms();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MultiProvider(
        providers: [

          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (_) => InternetProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => VibrationProvider()),
          ChangeNotifierProvider(create: (_) => AlarmSoundProvider()),
        ],
        child: const ExampleApp(),
      ),
    ),
  );
}




String _getDayName(DateTime date) {
  switch (date.weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return '';
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print('Stop action clicked (foreground)${response}');

      if (response.actionId == 'stop_action') {
        // You can also handle the stop logic here for foreground
        FlutterForegroundTask.stopService();
        print('Stop action clicked (foreground)');
      }

      if (response.actionId == 'snooze_action') {
        final player = AudioPlayer();
        await player.dispose();
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

}
@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse notificationResponse) async {
  print('Stop action clicked (foreground)${notificationResponse}');

  if (notificationResponse.actionId == 'stop_action') {
    FlutterForegroundTask.stopService();
    // Handle stop logic here (e.g., stop radio/music)
    print('Stop action pressed');
  }

  if (notificationResponse.actionId == 'snooze_action') {
    final player = AudioPlayer();
    await player.dispose();
    print('Stop action pressed');
  }
}

class LocationTaskHandler extends TaskHandler {
  static const String launchAppCommand = 'launchApp';
  static const MethodChannel _channel = MethodChannel('com.example.alarm_fyp/launch');

  // Target geofence coordinates and radiu
  static const double targetLat = 31.5006077; // Example: San Francisco
  static const double targetLon = 74.3201645;
  static const double radius = 200;


  Future<void> _launchApp(String title, String message) async {
    try {
      await _channel.invokeMethod('launchApp');
    } catch (e) {
      print('Error launching app: $e');

      await flutterLocalNotificationsPlugin.cancel(0); // Clear any old one

      // ✅ Create a fresh AudioPlayer instance
      final player = AudioPlayer();

      // ✅ Listen for completion and then release + cancel notification
      player.onPlayerComplete.listen((event) async {
        await flutterLocalNotificationsPlugin.cancel(0);
        await player.dispose(); // Fully cleanup
      });

      // ✅ Start audio playback from asset
      await player.play(AssetSource('gifts-ringtone.mp3'));

      // ✅ Show persistent notification
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        message,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'geofence_channel',
            'Geofence Notifications',
            channelDescription: 'Notifications for geofence events',
            importance: Importance.max,
            priority: Priority.max,
            autoCancel: false,
            ongoing: true,
            playSound: false, // we play sound manually
            fullScreenIntent: true,
            largeIcon: const DrawableResourceAndroidBitmap('app_icon'), // optional
            icon: 'app_icon',
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction(
                'stop_action',
                'Stop',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              AndroidNotificationAction(
                'snooze_action',
                'Snooze',
                showsUserInterface: true,
                cancelNotification: true,
              ),
            ],
          ),
        ),
        payload: 'launch_app',
      );
    }
  }











  Future<void> _checkLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );


      FlutterForegroundTask.updateService(
        notificationTitle: 'Location Tracking',
        notificationText:'Geominder is tracking your location for location based alarms.',
        // 'Lat: ${position.latitude}, Lon: ${position.longitude},',
      );

      // Send position data to main isolate
      FlutterForegroundTask.sendDataToMain({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'distance': 0,
      });


      _loadAlarmData(LatLng(position.latitude, position.longitude));


    } catch (e) {
      print('Error getting location: $e');
    }
  }


  Future<void> _loadAlarmData(LatLng pos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedAlarms = prefs.getStringList('alarms') ?? [];

    List<Map<String, dynamic>> alarms    = storedAlarms
        .map((alarmJson) => jsonDecode(alarmJson) as Map<String, dynamic>)
        .toList();
    final now = DateTime.now();
    final today = _getDayName(now);
    for(int i=0;i<alarms.length;i++)
    {
      LatLng alarmlat=LatLng(double.parse( alarms[i]["latitude"].toString()), double.parse( alarms[i]["longitude"].toString()));

      // bool isshown=true;
      if (_calculateDistance(pos,alarmlat) <= radius && alarms[i]["alarm_days"].toString().contains(today)) {
        print("you have reached");
        // FlutterForegroundTask.launchApp();

        await _launchApp("You are near to the loaction for the alarm: "+alarms[i]["alarm_name"].toString().toString(),"Alarm Description: "+alarms[i]["alarm_description"].toString());
        // FlutterForegroundTask.stopService();

        // AlarmService.scheduleAlarm(
        //     title: "You are near to the loaction for the alarm:"+alarms[i]["alarm_name"].toString().toString(),
        //     body:"Alarm Description: "+alarms[i]["alarm_description"].toString()
        // );


        print("Alarm triggered hamd");

        // yahan
      }
      else
      {
        print("Not Matched");
      }
    }



  }

  double _calculateDistance(LatLng start, LatLng end) {

    return Geolocator.distanceBetween(start.latitude,start.longitude,end.latitude,end.longitude);
  }
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
    await _checkLocation();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    await _checkLocation();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('onDestroy(isTimeout: $isTimeout)');
  }

  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
    if (data == launchAppCommand) {
      _launchApp("test","noti");
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
    _launchApp("test2","testttt");
  }

  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
     alarmPath = context.read<AlarmSoundProvider>().selectedAlarm;
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadTheme(), // Load theme on startup
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                title: 'GeoMinder',
                useInheritedMediaQuery: true,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: kPrimaryColor,
                    brightness: Brightness.dark,
                  ),
                  brightness: Brightness.dark,
                ),
                themeMode: themeProvider.themeMode, // Apply theme mode from provider
                home: ExamplePage(),
              );
            },
          );
        },
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<StatefulWidget> createState() => ExamplePageState();
  static Future<ServiceRequestResult> startService2() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Location Service is running',
        notificationText: 'Tracking your location',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_launch', text: 'Open App'),
        ],
        notificationInitialRoute: '/second',
        callback: startCallback,
      );
    }
  }

}

class ExamplePageState extends State<ExamplePage> {
  final ValueNotifier<Object?> _taskDataListenable = ValueNotifier(null);


  Future<void> requestPermissions() async {
    // Request notification permission
    final NotificationPermission notificationPermission =
    await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
    ].request();

    if (!statuses[Permission.location]!.isGranted) {
      print('Location permission denied');
      // Optionally, prompt the user to enable location permissions in settings
      await openAppSettings();
    }
    if (!statuses[Permission.locationAlways]!.isGranted) {
      print('Background location permission denied');
      // Optionally, prompt the user to enable background location in settings
      await openAppSettings();
    }


    if (Platform.isAndroid) {
      // Request battery optimization exemption
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_service',
        channelName: 'Location Service Notification',
        channelDescription: 'This notification appears when location tracking is running.',
        onlyAlertOnce: true,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(25000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<ServiceRequestResult> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Location Service is running',
        notificationText: 'Tracking your location',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_launch', text: 'Open App'),
        ],
        notificationInitialRoute: '/second',
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> stopService() {
    return FlutterForegroundTask.stopService();
  }

  void _onReceiveTaskData(Object data) {
    print('onReceiveTaskData: $data');
    _taskDataListenable.value = data;
  }

  void _triggerLaunchApp() {
    FlutterForegroundTask.sendDataToTask(LocationTaskHandler.launchAppCommand);
  }


  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHandler.handleMethodCall(context);
    });


    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions();
      _initService();
    });
    startService();
    _setupAlarms();

  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    _taskDataListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _startService();
    return WithForegroundTask(
        child:    Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, kPrimaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      "assets/alarmlogo.png",
                      height: 200,
                      width: 200,
                    ),
                  ),
                  Text(
                    'Manage your tasks with Geominder',
                    style: CustomTextStyle.GeneralStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: kTextWhiteColor
                    ),
                  ),
                  SizedBox(height: 35),
                  // Add your buttons or other widgets here
                ],
              ),
            ),
          ),
        )


    );
  }
  Future<void> _setupAlarms() async {
    await Future.delayed(Duration(seconds: 3));
    final now = DateTime.now();
    final today = _getDayName(now);
    final prefs = await SharedPreferences.getInstance();
    final List<String> alarmsData = prefs.getStringList('task_alarms') ?? [];
    final alarms = alarmsData.map((e) => TaskAlarm.fromJson(e)).toList();
    for (int i = 0; i < alarms.length; i++) {
      final alarm = alarms[i];

      if (alarm.days.contains(today)) {

        final timeString = alarm.time; // e.g., 6:52 PM
        final timeParts = timeString.split(' ');
        final hourMinute = timeParts[0].split(':');
        int hour = int.parse(hourMinute[0]);
        int minute = int.parse(hourMinute[1]);
        final period = timeParts[1];

        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        DateTime alarmDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // If time already passed today, set for tomorrow

        if (alarmDateTime.hour == now.hour && alarmDateTime.minute == now.minute) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Mytask()),
          );
        }
        else
        {

          checkAutoLogin();


        }


      }
      else
      {
        checkAutoLogin();
      }

    }
    if(alarms.isEmpty)
    {
      checkAutoLogin();

    }
  }


  Future<void> checkAutoLogin() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseDatabase _database = FirebaseDatabase.instance;
    User? user = _auth.currentUser;
    if (user != null) {

      // Fetch user data from Firebase Database
      DatabaseReference userRef = _database.ref().child("users").child(user.uid);
      DatabaseEvent event = await userRef.once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        UserModel userModel = UserModel.fromMap(userData);

        // Store user data in Provider
        Provider.of<UserProvider>(context, listen: false).setUser(userModel);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBar(),));
      }
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginview(),));
    }
  }
  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
  Widget _buildLocationDataText() {
    return ValueListenableBuilder(
      valueListenable: _taskDataListenable,
      builder: (context, data, _) {
        String displayText = 'Waiting for location data...';
        if (data is Map) {
          displayText = 'Latitude: ${data['latitude']}\n'
              'Longitude: ${data['longitude']}\n'
              'Distance to target: ${data['distance'].toStringAsFixed(2)}m';
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Location Data:'),
              Text(displayText, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceControlButtons() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buttonBuilder('Start Service', onPressed: startService),
          buttonBuilder('Stop Service', onPressed: stopService),
          buttonBuilder('Trigger App Launch', onPressed: _triggerLaunchApp),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Pop this page'),
        ),
      ),
    );
  }
}

