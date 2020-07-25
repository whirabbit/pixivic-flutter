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
      appBar: PappBar(
        title: texts.title,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            descriptionLine(texts.appData),
            settingCell(texts.deleteData, texts.deleteDataDetail, () {
              print('test');
            }, leadingWidget: Text('test')),
            settingCell(texts.dataRemainTime, texts.dataRemainTimeDetail, () {
              print('test');
            }, leadingWidget: Text('test')),
            descriptionLine(texts.imageLoad),
            settingCell(texts.reviewQuality, texts.reviewQualityDetail, () { }),
            descriptionLine(texts.appUpdate),
            settingCell(texts.checkUpdate, texts.checkUpdateDetail, () { })
          ],
        ),
      ),
    );
  }

  Widget descriptionLine(String content) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: screen.setWidth(17)),
      height: screen.setHeight(35),
      color: Colors.grey[100],
      child: Text(
        content,
        style: TextStyle(fontSize: 14, color: Colors.orange),
      ),
    );
  }

  Widget settingCell(String title, String subTitle, VoidCallback onTap,
      {Widget leadingWidget}) {
    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      height: screen.setHeight(50),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.only(
                left: screen.setWidth(17),
                top: screen.setHeight(7),
                bottom: screen.setHeight(3),
                right: screen.setWidth(17)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: TextStyle(fontSize: 14),),
                    SizedBox(height: screen.setHeight(5)),
                    Text(subTitle, style: TextStyle(fontSize: 12, color: Colors.grey),),
                  ],
                ),
                leadingWidget != null ? leadingWidget : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
