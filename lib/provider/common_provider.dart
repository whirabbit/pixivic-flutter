import 'package:flutter/material.dart';

class CommentProvider with ChangeNotifier {
  double _height = 77;
  double get height => _height;
  bool detailPageIsLike;
//  bool get detailPageIsLike=> _detailPageIsLike;

  void changeHeight(double height) {
    _height = height;
    notifyListeners();
  }
  void changeIsLike(bool isLike) {
    detailPageIsLike=isLike;
    notifyListeners();
  }
}