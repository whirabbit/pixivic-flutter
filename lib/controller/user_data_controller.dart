import 'package:get/get.dart' hide Response;
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/data/common.dart';
import 'package:pixivic/function/identity.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/function/image_url.dart';

class UserDataController extends GetxController {
  final id = RxInt(0);
  final permissionLevel = RxInt(0);
  final star = RxInt(0);
  final phone = RxInt(0);

  final name = RxString('userName');
  final email = RxString('');
  final permissionLevelExpireDate = RxString('');
  final avatarLink = RxString('');
  // String signature;
  // String location;

  final isBindQQ = RxBool(false);
  final isCheckEmail = RxBool(false);

  @override
  void onInit() {
    print('UserDataController onInit');
    readDataFromPrefs();
    super.onInit();
  }

  @override
  void onClose() {
    print('UserDataController onClose');
    super.onClose();
  }

  void readDataFromPrefs() {
    id.value = prefs.getInt('id');
    permissionLevel.value = prefs.getInt('permissionLevel');
    star.value = prefs.getInt('star');

    name.value = prefs.getString('name');
    email.value = prefs.getString('email');
    permissionLevelExpireDate.value =
        prefs.getString('permissionLevelExpireDate');
    avatarLink.value = prefs.getString('avatarLink');
    // signature = prefs.getString('signature');
    // location = prefs.getString('location');

    isBindQQ.value = prefs.getBool('isBindQQ');
    isCheckEmail.value = prefs.getBool('isCheckEmail');
  }

  submitCode(String code) async {
    CancelFunc cancelLoading;
    try {
      cancelLoading = BotToast.showLoading();
      String url = '/users/${prefs.getInt('id')}/permissionLevel';
      Map<String, dynamic> queryParameters = {'exchangeCode': code};
      Response response =
          await dioPixivic.put(url, queryParameters: queryParameters);
      cancelLoading();
      BotToast.showSimpleNotification(title: response.data['message']);
      setPrefs(response.data['data']);
      readDataFromPrefs();
      getVipUrl();
    } catch (e) {
      cancelLoading();
    }
  }
}
