import 'package:flutter/material.dart';

class PageSwitchProvider with ChangeNotifier {
  //点击nav_bar页面切换索引
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  //判断是否从nav_bar点击
  bool _pageChanged = true;
  bool get judgePage => _pageChanged;

  //判断是否滚动
  bool _judgeScrolling = false;
  bool get judgeScrolling => _judgeScrolling;
  String _title;
  String get title => _title;
  
  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // 当页面切换时，将变量至于 true 以便触发相应的方法
  // 触发完成后，将变量至于 false
  void pageChanged(bool isChanged) {
    _pageChanged = isChanged;
//    notifyListeners();
  }

  void changeScrolling(bool judge) {
    _judgeScrolling = judge;
    notifyListeners();
  }

  void changeTitle(String title) {
    _title = title;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
