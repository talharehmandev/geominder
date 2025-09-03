import 'dart:async';
import 'package:alarm_fyp/services/alarmFun.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:alarm_fyp/widgets/common_drawer.dart';
import 'package:alarm_fyp/widgets/custom_appBar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import '../widgets/customPlaces_searchFiled.dart';
import 'location_based_alarm_module/create_locationAlarm.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController StartPointController = TextEditingController();
  final TextEditingController RouteNameController = TextEditingController();

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(40.7579787, -73.9881175), // fallback location
    zoom: 18.0,
  );

  List<Marker> _marker = [];
  LatLng? _lastSelectedPosition;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get location on startup
    // _setupAlarms();
  }


  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
          ? MapType.terrain
          : _currentMapType == MapType.terrain
          ? MapType.hybrid
          : MapType.normal;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _initialPosition = CameraPosition(target: currentLatLng, zoom: 18.0);
      _addMarker(currentLatLng);
    });

    _moveCamera(currentLatLng);
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 18.0),
      ),
    );
  }

  void _addMarker(LatLng position) {
    final newMarker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: const InfoWindow(title: 'Selected Location'),
    );

    setState(() {
      _marker.clear();
      _marker.add(newMarker);
      _lastSelectedPosition = position;
    });
  }

  void _onMapTapped(LatLng position) async {
    _addMarker(position);
    _moveCamera(position);

    // Reverse geocode the selected position to get the location name
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        // Get the location name (you can customize which part of the address you want to show)
        String locationName = placemarks[0].name ?? 'Unknown Location';  // Default to 'Unknown Location' if name is null

        // Print or update the UI
        print('Location Name: $locationName');

        // Set the location name in the StartPointController
        StartPointController.text = locationName;

        // Update your UI or pass the location name to the next screen
        setState(() {
          _lastSelectedPosition = position;
        });
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Common_Drawer(),
      appBar: CustomAppbar(title: "Home", actions: [
        InkWell(
            onTap: () {
              _toggleMapType();
               },
            child: Icon(Icons.map,color: kPrimaryColor,))
      ]),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              trafficEnabled: true,
              zoomControlsEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              initialCameraPosition: _initialPosition,
              markers: Set<Marker>.of(_marker),
              mapType: _currentMapType,
              compassEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: _onMapTapped,
            ),
          ),
          Positioned(
            top: 2.h,
            left: 2.w,
            right: 2.w,
            bottom: 1.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomPlaceSearchField(
                  controller: StartPointController,
                  hintText: 'Enter alarm location here...',
                  labelText: 'Alarm Location',
                  onLocationSelected: (lat, lng) {
                    final selectedPosition = LatLng(lat, lng);
                    _addMarker(selectedPosition);
                    _moveCamera(selectedPosition);
                  },
                ),
                SizedBox(height: 5.0),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_lastSelectedPosition != null) {
            // Use the text from the StartPointController for location name
            String locationName = StartPointController.text.isNotEmpty
                ? StartPointController.text
                : 'Unknown Location'; // Default to 'Unknown Location' if no name is provided

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => locationAlarm(
                   location: _lastSelectedPosition!,
                   locationName: locationName,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select a location on the map first.')),
            );
          }
        },
        backgroundColor: kPrimaryColor,
        icon: Icon(Icons.alarm, color: Colors.white),
        label: Text(
          'Set Alarm',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

