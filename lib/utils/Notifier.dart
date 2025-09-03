import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LocationNotifier extends ChangeNotifier {

  LatLng? _currentLocation;
  LatLng? _DeviatedLocation;
  double? DistanceFromRoute;
  double? _currentHeading;
  double? acuracy;
  double? Speed;
  double? bearing=45;
   List<Marker> _markers = [];
   String progressmessage="";
   bool hideroute=false;
   late IconData IconDataInstruction=Icons.warning;

  LatLng? get currentLocation => _currentLocation;
  double? get getheading => _currentHeading;
  double? get getacuracy => acuracy;
  LatLng? get DeviatedLocation => _DeviatedLocation;
  List<Marker> get markers => _markers;
  String get getprogress => progressmessage;
  IconData get geticondata => IconDataInstruction;
  double? get getspeed => Speed;
  double? get gerbeering => bearing;
  bool get gethideroute => hideroute;

  void updateLocation(LatLng newLocation) {
    _currentLocation = newLocation;


    notifyListeners(); // Notify all listeners
  }
  void updateacuracy(double acurate) {
    acuracy = acurate;


    notifyListeners(); // Notify all listeners
  }
  void updateSpeed(double speed) {
    Speed = speed;


    notifyListeners(); // Notify all listeners
  }

  void updatehideroute(bool hide) {
    hideroute = hide;


    notifyListeners(); // Notify all listeners
  }

  void updateDeviatedLocation(LatLng newLocation) {
    _DeviatedLocation = newLocation;


    notifyListeners(); // Notify all listeners
  }
  void UpdateLiveMarkers(List<Marker> _markers2) {
    _markers = _markers2;


    notifyListeners(); // Notify all listeners
  }
  void updateDistance(double distance) {
    DistanceFromRoute = distance;


    notifyListeners(); // Notify all listeners
  }
  void updateheading(double head) {
    _currentHeading = head;


    notifyListeners(); // Notify all listeners
  }
  void updatebearing(double bearing) {
    bearing = bearing;


    notifyListeners(); // Notify all listeners
  }


  void updateprogress(String message ) {
    progressmessage = message;


    notifyListeners(); // Notify all listeners
  }

  void updateicon( IconData  data ) {
    IconDataInstruction = data;


    notifyListeners(); // Notify all listeners
  }
}
