import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';

import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/data/common.dart';

class PhoneController extends GetxController {
  final hasPhone = false.obs;
  final isGetMessage = false.obs;
  final isfinished = false.obs;
  final isPhoneNotUsed = false.obs;
  final phoneNumber = 0.obs;
  final verificationCodeBase64 = ''.obs;

  String inputPhoneNumber = '';
  String inputVerificationCode = '';
  String inputMessageVerificationCode = '';
  String verificationCodeVid = '';

  @override
  void onInit() {
    // called immediately after the widget is allocated memory
    getPhoneState();
    getVerifyCode();
    super.onInit();
  }

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
    phoneNumber.value = prefs.getInt('phone');
    hasPhone.value = phoneNumber.value != 0 ? true : false;
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
    try {
      Map headers = {
        'vid': verificationCodeVid,
        'value': inputVerificationCode,
        'phone': inputPhoneNumber
      };
      Response response = await dioPixivic.get('/messageVerificationCode',
          options: Options(headers: headers));
      if (response.statusCode == 200) isGetMessage.value = true;
    } catch (e) {
      isGetMessage.value = false;
    }
  }

  // 绑定手机号码至账户
  bindPhoneNumber() async {
    try {
      Map headers = {
        'vid': inputPhoneNumber,
        'value': inputMessageVerificationCode,
      };
      int userId = prefs.get('id');
      Response response = await dioPixivic.get('/users/$userId/phone',
          options: Options(headers: headers));
      if (response.statusCode == 200) isfinished.value = true;
    } catch (e) {
      isfinished.value = false;
    }
  }
}
