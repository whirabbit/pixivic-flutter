import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart' hide Response;

import 'package:pixivic/data/texts.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/controller/user_data_controller.dart';

class VIPPage extends StatelessWidget {
  final TextEditingController codeInputTextEditingController =
      TextEditingController();
  final UserDataController userDataController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(
        title: TextZhUserPage().vipSpeed,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: ScreenUtil().setHeight(576),
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Container(
                width: ScreenUtil().setWidth(293),
                height: ScreenUtil().setHeight(112),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          left: ScreenUtil().setWidth(15),
                          top: ScreenUtil().setHeight(25),
                          bottom: ScreenUtil().setHeight(25),
                          child: Obx(
                            () => Hero(
                              tag: 'userAvater',
                              child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: ScreenUtil().setHeight(25),
                                  backgroundImage: AdvancedNetworkImage(
                                      userDataController.avatarLink.value,
                                      header: {
                                        'referer': 'https://pixivic.com'
                                      })),
                            ),
                          )),
                      Positioned(
                          left: ScreenUtil().setWidth(88),
                          top: ScreenUtil().setHeight(38),
                          bottom: ScreenUtil().setHeight(57),
                          child: Obx(
                            () => Text(
                              userDataController.name.value,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: ScreenUtil().setSp(14)),
                            ),
                          )),
                      Positioned(
                          left: ScreenUtil().setWidth(88),
                          top: ScreenUtil().setHeight(66),
                          // bottom: ScreenUtil().setHeight(32),
                          child: Obx(
                            () => FaIcon(
                              FontAwesomeIcons.gem,
                              color:
                                  userDataController.permissionLevel.value == 3
                                      ? Colors.orange
                                      : Colors.grey,
                              size: ScreenUtil().setWidth(13),
                            ),
                          )),
                      Obx(
                        () => Positioned(
                            left: ScreenUtil().setWidth(107),
                            top: ScreenUtil().setHeight(63),
                            // bottom: ScreenUtil().setHeight(33),
                            child: userDataController.permissionLevel.value == 3
                                ? Text(
                                    TextZhVIP.endTime +
                                        DateFormat("yyyy-MM-dd").format(
                                            DateTime.parse(userDataController
                                                .permissionLevelExpireDate
                                                .value)),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w300,
                                      fontSize: ScreenUtil().setSp(12),
                                    ))
                                : Text(TextZhVIP.notVip,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w300,
                                      fontSize: ScreenUtil().setSp(12),
                                    ))),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(293),
                height: ScreenUtil().setHeight(146),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: ScreenUtil().setWidth(111),
                        right: ScreenUtil().setWidth(111),
                        top: ScreenUtil().setHeight(14),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(TextZhVIP.code,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                  fontSize: ScreenUtil().setSp(14))),
                        ),
                      ),
                      Positioned(
                          left: ScreenUtil().setWidth(42),
                          right: ScreenUtil().setWidth(42),
                          top: ScreenUtil().setHeight(42),
                          child: TextField(
                            controller: codeInputTextEditingController,
                          )),
                      Positioned(
                          left: ScreenUtil().setWidth(90),
                          right: ScreenUtil().setWidth(90),
                          top: ScreenUtil().setHeight(71),
                          child: FlatButton(
                            child: Text(TextZhVIP.convert,
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w300,
                                    fontSize: ScreenUtil().setSp(12))),
                            onPressed: () {
                              userDataController.submitCode(
                                  codeInputTextEditingController.text);
                              codeInputTextEditingController.clear();
                            },
                          )),
                      Positioned(
                          left: ScreenUtil().setWidth(110),
                          top: ScreenUtil().setHeight(107),
                          bottom: ScreenUtil().setHeight(15),
                          child: GestureDetector(
                            child: FaIcon(
                              FontAwesomeIcons.alipay,
                              color: Colors.blue,
                              size: ScreenUtil().setWidth(26),
                            ),
                            onTap: () async {
                              const url = 'https://mall.pixivic.net/product/';
                              if (await canLaunch(url)) {
                                await launch(
                                  url,
                                  forceSafariVC: false,
                                  forceWebView: false,
                                );
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          )),
                      Positioned(
                          left: ScreenUtil().setWidth(156),
                          top: ScreenUtil().setHeight(107),
                          bottom: ScreenUtil().setHeight(15),
                          child: GestureDetector(
                            child: FaIcon(
                              FontAwesomeIcons.weixin,
                              color: Colors.green,
                              size: ScreenUtil().setWidth(26),
                            ),
                            onTap: () async {
                              const url =
                                  'https://weidian.com/?userid=1676062924';
                              if (await canLaunch(url)) {
                                await launch(
                                  url,
                                  forceSafariVC: false,
                                  forceWebView: false,
                                );
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          )),
                    ],
                  ),
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(293),
                height: ScreenUtil().setHeight(108),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: ScreenUtil().setWidth(15),
                        top: ScreenUtil().setHeight(21),
                        bottom: ScreenUtil().setHeight(21),
                        child: Lottie.asset(
                          'image/train-speed.json',
                          repeat: true,
                          height: ScreenUtil().setHeight(66),
                        ),
                      ),
                      Positioned(
                          left: ScreenUtil().setWidth(132),
                          top: ScreenUtil().setHeight(43),
                          bottom: ScreenUtil().setHeight(43),
                          child: FlatButton(
                            child: Text(TextZhVIP.learnMore,
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w300,
                                    fontSize: ScreenUtil().setSp(12))),
                            onPressed: () async{
                              const url = 'https://m.pixivic.com/handbook';
                              if (await canLaunch(url)) {
                                await launch(
                                  url,
                                  forceSafariVC: false,
                                  forceWebView: false,
                                );
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
