import 'package:flutter/material.dart';

// TODO: work with login
class UserStateProvider with ChangeNotifier {
  bool loginState = false;

  void changeLogin(bool state) {
    loginState = state;
    notifyListeners();
  }
}
