import 'package:get/get.dart';

import 'package:pixivic/data/common.dart';

class UserDataController extends GetxController {
  int id;
  int permissionLevel;
  int star;

  String name;
  String email;
  String permissionLevelExpireDate;
  String avatarLink;
  // String signature;
  // String location;

  bool isBindQQ;
  bool isCheckEmail;

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

  @override
  void onDetached() {
    print('UserDataController onDetached');
  }

  @override
  void onResumed() {
    print('UserDataController onResumed');
  }

  void readDataFromPrefs() {
    id = prefs.getInt('id');
    permissionLevel = prefs.getInt('permissionLevel');
    star = prefs.getInt('star');

    name = prefs.getString('username').obs();
    email = prefs.getString('email');
    permissionLevelExpireDate = prefs.getString('permissionLevelExpireDate');
    avatarLink = prefs.getString('avatarLink');
    // signature = prefs.getString('signature');
    // location = prefs.getString('location');

    isBindQQ = prefs.getBool('isBindQQ');
    isCheckEmail = prefs.getBool('isCheckEmail');
  }
}
