import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import '../data/common.dart';
import '../widget/papp_bar.dart';
import '../data/texts.dart';
import '../sidepage/about_page.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextZhSettingPage texts = TextZhSettingPage();
  ScreenUtil screen = ScreenUtil();
  
  double cacheSize = 0;
  String previewQuality = prefs.getString('previewQuality');

  @override
  void initState() {
    _readCacheSize();
    super.initState();
  }

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
            settingCell(texts.deleteData, texts.deleteDataDetail, _clearCache,
                leadingWidget: cacheDisplay()),
            settingCell(texts.dataRemainTime, texts.dataRemainTimeDetail, () {
              print('test');
            }, leadingWidget: Text('test')),
            descriptionLine(texts.imageLoad),
            settingCell(texts.reviewQuality, texts.reviewQualityDetail, () {}, leadingWidget: previewQualityDisplay()),
            descriptionLine(texts.appUpdate),
            settingCell(
                texts.checkUpdate, texts.checkUpdateDetail, _routeToAboutPage)
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
                    Text(
                      title,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: screen.setHeight(5)),
                    Text(
                      subTitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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

  Widget cacheDisplay() {
    return Text(
        "${cacheSize.toStringAsFixed(2)} ${texts.deleteDataDetailUnit}");
  }

  Widget previewQualityDisplay() {
    String showText;
    if(previewQuality == 'medium') 
      showText = texts.mediumQuality;
    else if(previewQuality == 'large')
      showText = texts.highQuality;
    else 
      showText = texts.lowQuality;
    return Text(showText);
  }

  _clearCache() async {
    await DiskCache().clear();
    _readCacheSize();
  }

  _readCacheSize() {
    DiskCache().cacheSize().then((value) {
      setState(() {
        cacheSize = value / 1024 / 1024;
      });
    });
  }

  _routeToAboutPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AboutPage()));
  }
}
