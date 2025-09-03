import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _dialogShown = false;

  bool get isConnected => _isConnected;
  bool get isDialogShown => _dialogShown;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  InternetProvider() {
    _checkInternet();
  }

  void _checkInternet() {
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      bool hasInternet = await _hasInternetAccess();
      if (_isConnected != hasInternet) {
        _isConnected = hasInternet;
        notifyListeners();
      }
    });
  }

  ///  **Checks actual internet access by pinging Google**
  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void setDialogShown(bool value) {
    _dialogShown = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}