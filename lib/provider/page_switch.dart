import 'package:flutter/material.dart';

class PageSwitchProvider with ChangeNotifier{
  //点击nav_bar页面切换索引
  int _currentIndex =0;
  int get currentIndex => _currentIndex;
  //判断是否从nav_bar点击
  bool _judgePage=true;
  bool get judgePage=>_judgePage;
  //判断是否滚动
  bool _judgeScrolling=false;
  bool get judgeScrolling=>_judgeScrolling;
  void changeIndex(int index){
    _currentIndex=index;
    notifyListeners();
  }
  void changeJudge(bool judge){
    _judgePage=judge;
//    notifyListeners();
  }
  void changeScrolling(bool judge){
    _judgeScrolling=judge;
    notifyListeners();
  }
  @override
  void dispose(){
    super.dispose();
  }
}