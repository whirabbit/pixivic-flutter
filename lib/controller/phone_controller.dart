import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/data/common.dart';

class PhoneController extends GetxController {
  final hasPhone = false.obs;
  final isGetMessage = false.obs;
  final isfinished = false.obs;
  final isPhoneNotUsed = false.obs;
  final phoneNumber = ''.obs;
  final verificationCodeBase64 = ''.obs;

  String inputPhoneNumber = '';
  String finalPhoneNumber;
  String inputVerificationCode = '';
  String inputMessageVerificationCode = '';
  String verificationCodeVid = '';

  @override
  void onInit() {
    // called immediately after the widget is allocated memory
    print('init phone controller');
    getPhoneState();
    // getVerifyCode();
    super.onInit();
  }

  @override
  void onClose() {
    print('Close phone controller');
  }

  void changeInputVerificationCode(String value) =>
      inputMessageVerificationCode = value;
  void changeInputMessageVerificationCode(String value) =>
      inputMessageVerificationCode = value;
  void changeInputPhoneNumber(String value) => inputPhoneNumber = value;

  // 获取图片验证码
  getVerifyCode() async {
    try {
      Response response = await dioPixivic.get('/verificationCode');
      verificationCodeVid = response.data['data']['vid'];
      verificationCodeBase64.value = response.data['data']['imageBase64'];
    } catch (e) {}
  }

  // 获取用户手机号绑定状态
  getPhoneState() {
    phoneNumber.value = prefs.getString('phone');
    hasPhone.value = phoneNumber.value != '' ? true : false;
  }

  // 获取用户输入的手机号的绑定状态
  getPhoneUsedState() async {
    try {
      Response response =
          await dioPixivic.get('/users/phones/$inputPhoneNumber');
      if (response.statusCode == 200) isPhoneNotUsed.value = true;
    } catch (e) {
      isPhoneNotUsed.value = false;
    }
  }

  // 向用户手机发送验证码
  getMessageCode() async {
    Response response;
    try {
      Map<String, dynamic> queryParameters = {
        'vid': verificationCodeVid,
        'value': inputVerificationCode,
        'phone': inputPhoneNumber.toString()
      };
      response = await dioPixivic.get('/messageVerificationCode',
          queryParameters: queryParameters);
      if (response.statusCode == 200) isGetMessage.value = true;
      finalPhoneNumber = inputPhoneNumber;
    } catch (e) {
      print('==================');
      print(e);
      getVerifyCode();
      isGetMessage.value = false;
    }
  }

  onTapGetMessage() async {
    if (inputVerificationCode != '') {
      bool isPhoneNumber = RegExp(r'^(?:[+0]9)?[0-9]{11}$')
          .hasMatch(inputPhoneNumber.toString());
      if (isPhoneNumber) {
        await getPhoneUsedState();
        if (isPhoneNotUsed.value) getMessageCode();
      } else {
        BotToast.showSimpleNotification(title: '请输入正确的手机号码');
      }
    } else {
      BotToast.showSimpleNotification(title: '请输入验证码');
    }
  }

  // 绑定手机号码至账户
  bindPhoneNumber() async {
    try {
      Map<String, dynamic> queryParameters = {
        'vid': inputPhoneNumber,
        'value': inputMessageVerificationCode,
      };
      int userId = prefs.get('id');
      Response response = await dioPixivic.get('/users/$userId/phone',
          queryParameters: queryParameters);
      if (response.statusCode == 200) isfinished.value = true;
      // prefs.setInt(key, value);
      Get.back();
    } catch (e) {
      isfinished.value = false;
    }
  }

  exit() {
    verificationCodeBase64.value = '';
    isPhoneNotUsed.value = false;
    isGetMessage.value = false;
    isfinished.value = false;
    inputVerificationCode = '';
    inputMessageVerificationCode = '';
    getPhoneState();
  }
}
