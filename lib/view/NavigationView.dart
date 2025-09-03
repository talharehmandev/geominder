import 'dart:convert';
import 'dart:io';
import 'package:alarm_fyp/services/geominder_apis.dart';
import 'package:alarm_fyp/utils/Primary_text.dart';
import 'package:alarm_fyp/utils/constants.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../widgets/customPlaces_searchFiled.dart';
import '../widgets/custom_appBar.dart';

class RouteMap extends StatefulWidget {
  @override
  _RouteMapState createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _mapController;
  List<Marker> _markers = [];
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  String selectedMode = "bicycling";
  String googleApiKey = "${Constants.googleMap_apiKey}";
  String total_distance = '';
  String total_duration = '';
  Position? _currentPosition;
  MapType _currentMapType = MapType.normal;

  final TextEditingController StartPointController = TextEditingController();

  void _addDestinationMarker(LatLng position) async {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: position,
          infoWindow: InfoWindow(title: 'Destination'),
        ),
      );
    });

    // Move the camera to the new destination
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15, // You can adjust zoom level if you want
        ),
      ),
    );

    _getRouteAndDrawPolyline();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
    });

    // Move camera to current location
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );

    if (_markers.length > 1) {
      _getRouteAndDrawPolyline();
    }
  }

  void _getRouteAndDrawPolyline() async {
    if (_markers.length < 2 || _currentPosition == null) return;

    polylineCoordinates.clear();

    final origin = _currentPosition;
    final destination = _markers.last.position;

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin!.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    print(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];

      if (routes.isNotEmpty) {
        final polylinePoints = routes[0]['overview_polyline']['points'];
        polylineCoordinates.addAll(_decodePolyline(polylinePoints));
      }
    } else {
      print('Failed to fetch directions: ${response.body}');
    }

    _drawPolyline();
    _calculateTotalDistance();
  }

  void _calculateTotalDistance() async {
    String origins =
        "${_currentPosition!.latitude},${_currentPosition!.longitude}";
    String destinations =
        "${_markers.last.position.latitude},${_markers.last.position.longitude}";

    String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origins&destinations=$destinations&key=$googleApiKey";

    print(url);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> data = json.decode(response.body);
        double totalDistance = 0.0;
        int totalDuration = 0;

        if (data["status"] == "OK") {
          List elements = data["rows"][0]["elements"];

          for (var element in elements) {
            if (element["status"] == "OK") {
              totalDistance += element["distance"]["value"].toDouble();
              totalDuration += (element["duration"]["value"] as num).toInt();
            }
          }

          double distanceInKm = totalDistance / 1000;
          double durationInMinutes = totalDuration / 60;

          setState(() {
            total_distance = "${distanceInKm.toStringAsFixed(2)} km";
            total_duration = "${durationInMinutes.toStringAsFixed(2)} Min";
          });

          debugPrint("Total Distance (API): $total_distance");
          debugPrint("Total Duration (API): $total_duration");
        } else {
          debugPrint("API Error: ${data["status"]}");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  void _drawPolyline() {
    if (polylineCoordinates.isEmpty) return;
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: kPrimaryColor,
          width: 8,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _startNavigationWithIntent() {
    if (_currentPosition == null || _markers.length < 2) return;

    final destinationLat = _markers.last.position.latitude;
    final destinationLng = _markers.last.position.longitude;

    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data:
            'google.navigation:q=$destinationLat,$destinationLng&mode=$selectedMode',
        package: 'com.google.android.apps.maps',
      );
      intent.launch().catchError((e) {
        print('Error launching Google Maps: $e');
      });
    } else {
      print("This method works only on Android.");
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal
              ? MapType.satellite
              : _currentMapType == MapType.satellite
              ? MapType.terrain
              : _currentMapType == MapType.terrain
              ? MapType.hybrid
              : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: "Navigate to Destination",
        actions: [
          InkWell(
            onTap: () {
              _toggleMapType();
            },
            child: Icon(Icons.map, color: kPrimaryColor),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: kPrimaryColor),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            trafficEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,

            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target:
                  _currentPosition != null
                      ? LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                      : LatLng(37.7749, -122.4194),
              zoom: 10,
            ),
            markers: Set.from(_markers),
            polylines: _polylines,
            onTap: (LatLng position) {
              _addDestinationMarker(position);
            },
          ),

          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Column(
              children: [
                CustomPlaceSearchField(
                  controller: StartPointController,
                  hintText: 'Enter your destination here...',
                  labelText: 'Destination',
                  onLocationSelected: (lat, lng) {
                    final selectedPosition = LatLng(lat, lng);
                    _addDestinationMarker(selectedPosition);
                  },
                ),
                SizedBox(height: 8),
                if (total_distance.isNotEmpty && total_duration.isNotEmpty)
                  Container(
                    width: 100.w,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Distance: $total_distance, Duration: $total_duration",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kTextWhiteColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _startNavigationWithIntent();
        },
        icon: Icon(Icons.navigation, color: kTextWhiteColor),
        label: Text(
          "Navigate",
          style: CustomTextStyle.headingStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19.sp,
            color: kTextWhiteColor,
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
