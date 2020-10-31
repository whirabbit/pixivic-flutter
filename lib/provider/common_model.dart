import 'package:flutter/material.dart';

// TODO： name need to be changed?
class CommonModel with ChangeNotifier {
  double _height = 77;

  double get height => _height;

  void changeHeight(double height) {
    _height = height;
    notifyListeners();
  }
}
