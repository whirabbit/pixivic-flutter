import 'package:flutter/material.dart';

// TODO: Useless?
class UserStateProvider with ChangeNotifier {
  bool loginState = false;

  void changeLogin(bool state) {
    loginState = state;
    notifyListeners();
  }
}
