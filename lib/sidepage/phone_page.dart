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
        child: Column(
          children: [],
        ),
      ),
    );
  }

  Widget imageVerification() {
    return singleLineCell(Row(
      children: [Text('图形验证码'), TextField(), Image(image: null)],
    ));
  }

  Widget phoneNumber() {
    return singleLineCell(Row(
      children: [Text('手机号'), TextField(), FlatButton()],
    ));
  }

  Widget phoneVerification() {
    return singleLineCell(Row(
      children: [Text('手机验证码'), TextField(), FlatButton()],
    ));
  }

  Widget singleLineCell(Widget childWidget) {
    return Container(
      height: ScreenUtil().setHeight(30),
      alignment: Alignment.centerLeft,
      child: childWidget,
    );
  }
}
