import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/controller/phone_controller.dart';

class PhonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PhoneController phoneController = Get.put(PhoneController());

    return Scaffold(
      appBar: PappBar(title: '绑定手机'),
      body: Container(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(100)),
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            imageVerification(),
            phoneNumber(),
            phoneVerification(),
          ],
        ),
      ),
    );
  }

  Widget imageVerification() {
    return singleLineCell(
        '图形验证码',
        FlatButton(
          child: Text('获取短信'),
        ));
  }

  Widget phoneNumber() {
    return singleLineCell(
        '手机号',
        FlatButton(
          child: Text('获取短信'),
        ));
  }

  Widget phoneVerification() {
    return singleLineCell(
        '手机验证码',
        FlatButton(
          child: Text('获取短信'),
        ));
  }

  Widget customTextField(String hintText) {
    return Container(
      width: ScreenUtil().setWidth(150),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        ),
      ),
    );
  }

  Widget singleLineCell(String text, Widget leadingWidget) {
    return Container(
        height: ScreenUtil().setHeight(45),
        width: ScreenUtil().setWidth(240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                // Container(
                //   width: ScreenUtil().setWidth(80),
                //   padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                //   alignment: Alignment.centerLeft,
                //   child: Text(text),
                // ),
                customTextField(text),
                Container(
                  width: ScreenUtil().setWidth(90),
                  alignment: Alignment.center,
                  child: leadingWidget,
                ),
              ],
            ),
            SizedBox(
              width: ScreenUtil().setWidth(240),
              child: Divider(color: Colors.grey),
            )
          ],
        ));
  }
}
