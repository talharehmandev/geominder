import 'package:flutter/material.dart';

import '../models/user_data_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel userModel) {
    _user = userModel;
    notifyListeners();
  }
}
