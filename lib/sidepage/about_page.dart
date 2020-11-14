import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:pixivic/data/texts.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/function/update.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  TextZhForAboutPage texts = TextZhForAboutPage();
  TextStyle textStyleNormal =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w300);
  TextStyle textStyleButton =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w900);

  @override
  Widget build(BuildContext context) {
    bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Scaffold(
      appBar: PappBar(title: texts.title),
      body: SingleChildScrollView(
        child: Container(
          // height: ScreenUtil().setHeight(530),
          child: Wrap(
            direction: Axis.horizontal,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
                child: Image.asset(
                  'image/center_gril.gif',
                  width: ScreenUtil().setWidth(130),
                  height: ScreenUtil().setWidth(130),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(7)),
                child: Text(
                  texts.versionInfo,
                  style: textStyleNormal,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(7)),
                child: Text(
                  texts.updateTitle,
                  style: textStyleNormal,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(17)),
                child: Text(
                  texts.updateInfo,
                  style: textStyleNormal,
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      linkButton(TextZhForAboutPage().donate,
                          'https://m.pixivic.com/links?VNK=9fa02e17'),
                      isAndroid ? checkUpdateButton() : Container(),
                      linkButton(texts.webOfficial, 'https://pixivic.com/')
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget linkButton(String value, String url) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(3)),
      child: Material(
        child: InkWell(
          onTap: () async {
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: Text(
            value,
            style: textStyleButton,
          ),
        ),
      ),
    );
  }

  Widget checkUpdateButton() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(3)),
      child: Material(
        child: InkWell(
          onTap: () async {
            if (Theme.of(context).platform == TargetPlatform.android) {
             FlutterBugly.checkUpgrade().then((UpgradeInfo info) {
               print('==============================');
               if (info != null && info.id != null) {
                 UpdateApp().showUpdateDialog(
                     context, info.versionName, info.newFeature, info.apkUrl);
               } else {
                 BotToast.showSimpleNotification(title: texts.noUpdate);
               }
             });
            } else {}
          },
          child: Text(
            texts.checkUpdate,
            style: textStyleButton,
          ),
        ),
      ),
    );
  }
}
