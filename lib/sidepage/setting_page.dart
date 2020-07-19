import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/common.dart';
import '../widget/papp_bar.dart';
import '../data/texts.dart';


class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextZhSettingPage texts = TextZhSettingPage();
  ScreenUtil screen = ScreenUtil();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(title: texts.title,),
      body: Container(),
    );
  }

  Widget descriptionLine(String content) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: screen.setWidth(8)),
      height: screen.setHeight(30),
      color: Colors.grey[100],
      child: Text(content, style: TextStyle(fontSize: 11, color: Colors.white),),
    );
  }

  Widget settingCell(String title, String subTitle, int leadingWidgetType, VoidCallback onTap) {
    Widget leadingWidget;

    

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: screen.setWidth(8)),
      height: screen.setHeight(25),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[

            ],
          ),
          leadingWidget,
        ],
      ),
    );
  }
}