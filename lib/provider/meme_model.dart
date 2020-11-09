import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class MemeModel with ChangeNotifier {
  Map memeMap;

  MemeModel() {
    rootBundle.loadString('image/meme/meme.json').then((value) {
      memeMap = jsonDecode(value);
      print(memeMap);
      notifyListeners();
    });
  }
}
