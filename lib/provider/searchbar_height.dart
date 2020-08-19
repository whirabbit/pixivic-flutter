import 'package:flutter/material.dart';

class SearchBarHeightProvider with ChangeNotifier {
  double _height = 77;
  double get height => _height;

  void changeHeight(double height) {
    _height = height;
    notifyListeners();
  }
}