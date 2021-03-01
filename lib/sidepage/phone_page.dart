import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pixivic/controller/phone_controller.dart';
import 'package:pixivic/data/common.dart';

class PhonePage extends StatelessWidget {
  final PhoneController phoneController = Get.put(PhoneController());

  @override
  Widget build(BuildContext context) {
    print('rebuild build');
    phoneController.getPhoneState();
    return !phoneController.hasPhone.value
        ? phoneBindView(context)
        : hasPhoneView();
  }

  Widget phoneBindView(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              ScreenUtil().setHeight(75),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(15),
                top: ScreenUtil().setHeight(10),
                bottom: ScreenUtil().setHeight(10),
              ),
              child: Text(
                '绑定手机号',
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(324),
              alignment: Alignment.center,
              child: Column(
                children: [
                  imageVerification(),
                  phoneNumber(),
                  phoneVerification(),
                ],
              ),
            )
          ],
        ));
  }

  Widget hasPhoneView() {
    return Container(
      alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(30),
          bottom: ScreenUtil().setHeight(30),
          left: ScreenUtil().setWidth(20)
        ),
      child: Text('手机号已绑定:${prefs.getString('phone')}',style: TextStyle(
        fontSize: ScreenUtil().setSp(16)
      ),),
    );
  }

  Widget imageVerification() {
    print('Rebuild imageVerification');
    return singleLineCell(
        '图形验证码',
        TextInputType.text,
        phoneController.changeInputVerificationCode,
        Obx(() => phoneController.verificationCodeBase64.value != ''
            ? Image.memory(
                base64Decode(phoneController.verificationCodeBase64.value),
                width: ScreenUtil().setWidth(70),
              )
            : Container()));
  }

  Widget phoneNumber() {
    print('Rebuild phoneNumber');
    return singleLineCell(
        '手机号',
        TextInputType.phone,
        phoneController.changeInputPhoneNumber,
        Obx(() => customButton(
            '获取验证码',
            !phoneController.isGetMessage.value
                ? () {
                    phoneController.onTapGetMessage();
                  }
                : null)));
  }

  Widget phoneVerification() {
    print('Rebuild phoneVerification');
    return singleLineCell(
        '手机验证码',
        TextInputType.number,
        phoneController.changeInputMessageVerificationCode,
        Obx(() => phoneController.isBindBtnLock.value
            ? customButton('立即绑定', null)
            : customButton('立即绑定', phoneController.onTapBindPhoneNumber)));
  }

  Widget customButton(String text, VoidCallback onTapped) {
    return RaisedButton(
        color: Colors.blue[300],
        child: Text(
          text,
          style:
              TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(12)),
        ),
        onPressed: onTapped);
  }

  Widget customTextField(String hintText, TextInputType textInputType,
      ValueChanged<String> onChanged) {
    return Container(
      width: ScreenUtil().setWidth(150),
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
      child: TextField(
        onChanged: onChanged,
        keyboardType: textInputType,
        cursorColor: Colors.orange,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: ScreenUtil().setSp(12)),
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 5, top: 11, right: 15),
        ),
      ),
    );
  }

  Widget singleLineCell(String text, TextInputType textInputTypeWidget,
      ValueChanged<String> onChanged, leadingWidget) {
    return Container(
        height: ScreenUtil().setHeight(45),
        width: ScreenUtil().setWidth(240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customTextField(
                  text,
                  textInputTypeWidget,
                  onChanged,
                ),
                Container(
                  width: ScreenUtil().setWidth(90),
                  alignment: Alignment.center,
                  child: leadingWidget,
                ),
              ],
            ),
            SizedBox(
              width: ScreenUtil().setWidth(240),
              height: ScreenUtil().setHeight(2),
              child: Divider(color: Colors.grey),
            )
          ],
        ));
  }
}
