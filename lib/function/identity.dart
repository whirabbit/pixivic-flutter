import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../data/common.dart';
import '../data/texts.dart';
import 'package:pixivic/provider/collection_model.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/controller/user_data_controller.dart';

// identity.dart 文件包含与用户身份验证相关的所有方法，例如登录，验证 auth 是否过期，注册等等

// 缺少刷新流程
login(BuildContext context, String userName, String pwd,
    String verificationCode, String verificationInput,
    {String widgetFrom}) async {
  String url =
      'https://pix.ipv4.host/users/token?vid=$verificationCode&value=$verificationInput';
  Map<String, String> body = {'username': userName, 'password': pwd};
  Map<String, String> header = {'Content-Type': 'application/json'};
  var encoder = JsonEncoder.withIndent("     ");
  var client = http.Client();
  var response =
      await client.post(url, headers: header, body: encoder.convert(body));
  if (response.statusCode == 200) {
    prefs.setString('auth', response.headers['authorization']);
    print(prefs.getString('auth'));
    Map data = jsonDecode(
        utf8.decode(response.bodyBytes, allowMalformed: true))['data'];
    // print(data);

    setPrefs(data);

    isLogin = true;
    BotToast.showSimpleNotification(title: TextZhLoginPage().loginSucceed);
    print(newPageKey);
    print(userPageKey);
    // 为 dio 单例添加 auth
    if (widgetFrom != null) {
      switch (widgetFrom) {
        case 'newPage':
          newPageKey.currentState.checkLoginState();
          break;
        case 'userPage':
          userPageKey.currentState.checkLoginState();
          break;
        default:
          break;
      }
    }
    // 清除 picpage 页面缓存以便重新加载
    homeScrollerPosition = 0;
    homePicList = [];
    homeCurrentPage = 1;
    // 加载用户的画集列表
    Provider.of<CollectionUserDataModel>(context, listen: false)
        .getCollectionList();
    Get.find<UserDataController>().readDataFromPrefs();
  } else {
    // isLogin = false;
    BotToast.showSimpleNotification(
        title: jsonDecode(
            utf8.decode(response.bodyBytes, allowMalformed: true))['message']);
  }
  tempVerificationCode = null;
  tempVerificationImage = null;
  return response.statusCode;
}

logout(BuildContext context, {bool isInit = false}) {
  // TODO: UI 刷新
  clearPrefs();
  isLogin = false;
  if (!isInit) {
    userPageKey.currentState.checkLoginState();
    // 清除 picpage 页面缓存以便重新加载
    homeScrollerPosition = 0;
    homePicList = [];
    homeCurrentPage = 1;
    // 清除用户的画集列表
    Provider.of<CollectionUserDataModel>(context, listen: false)
        .cleanUserCollectionList();
  }
}

reloadUserData() async {
  print('identity.dart: reload user data');
  String authStored = prefs.getString('auth');
  if (authStored == null || authStored == '')
    return false;
  else {
    String url = '/users/${prefs.getInt('id')}';
    try {
      Response response = await dioPixivic.get(url);
      if (response.statusCode == 200) {
        Map data = response.data['data'];
        setPrefs(data);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

setPrefs(Map data) {
  prefs.setInt('id', data['id']);
  prefs.setInt('permissionLevel', data['permissionLevel']);
  prefs.setInt('star', data['star']);
  prefs.setInt('phone', data['phone'] != null ? data['phone'] : 0);

  prefs.setString('name', data['username']);
  prefs.setString('email', data['email']);
  prefs.setString(
      'permissionLevelExpireDate', data['permissionLevelExpireDate']);
  prefs.setString('avatarLink',
      'https://static.pixivic.net/avatar/299x299/${data['id']}.jpg');
  if (data['signature'] != null)
    prefs.setString('signature', data['signature']);
  if (data['location'] != null) prefs.setString('location', data['location']);

  prefs.setBool('isBindQQ', data['isBindQQ']);
  prefs.setBool('isCheckEmail', data['isCheckEmail']);
}

clearPrefs() {
  prefs.setString('auth', '');
  prefs.setInt('id', 0);
  prefs.setInt('permissionLevel', 0);
  prefs.setInt('star', 0);

  prefs.setString('name', '');
  prefs.setString('email', '');
  prefs.setString('permissionLevelExpireDate', '');
  prefs.setString('avatarLink', '');

  prefs.setBool('isBindQQ', false);
  prefs.setBool('isCheckEmail', false);
}

// checkAuth() async {
//   String authStored = prefs.getString('auth');
//   if (authStored == null || authStored == '')
//     return false;
//   else {
//     String url =
//         'https://pix.ipv4.host/users/${prefs.getInt('id').toString()}/isBindQQ';
//     Map<String, String> header = {
//       'Content-Type': 'application/json',
//       'authorization': authStored
//     };
//     var client = http.Client();
//     var response = await client.get(
//       url,
//       headers: header,
//     );
//     // print(response.statusCode);
//     // Map data = jsonDecode(
//     //     utf8.decode(response.bodyBytes, allowMalformed: true));
//     // print(data);
//     // print(response.headers['authorization']);
//     if (response.statusCode == 200) {
//       if (response.headers['authorization'] != null)
//         prefs.setString('auth', response.headers['authorization']);
//       return true;
//     } else if (response.statusCode == 401 || response.statusCode == 500) {
//       return false;
//     }
//   }
// }

register(String userName, String pwd, String pwdRepeat, String verificationCode,
    String verificationInput, String emailInput) async {
  // 检查用户名和邮箱，密码（新建邮箱controller)
  String url =
      'https://pix.ipv4.host/users/?vid=$verificationCode&value=$verificationInput';
  Map<String, String> body = {
    'username': userName,
    'email': emailInput,
    'password': pwd,
  };
  CancelFunc cancelLoading;
  Response response;
  try {
    cancelLoading = BotToast.showLoading();
    response = await dioPixivic.post(url, data: body);
    cancelLoading();
    if (response.statusCode == 200) {
      // 切换至login界面，并给出提示
      BotToast.showSimpleNotification(title: TextZhLoginPage().registerSucceed);
    } else {
      // isLogin = false;
      print(response.data['message']);
      BotToast.showSimpleNotification(title: response.data['message']);
    }
  } catch (e) {
    cancelLoading();
    return e.response.statusCode;
  }
  tempVerificationCode = null;
  tempVerificationImage = null;
  return response.statusCode;
}

checkRegisterInfo(
    String userName, String pwd, String pwdRepeat, String email) async {
  final String regexEmail =
      "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";
  if (pwd != pwdRepeat) {
    return TextZhLoginPage().errorPwdNotSame;
  }
  if (pwd.length < 8 || pwd.length > 20) {
    return TextZhLoginPage().errorPwdLength;
  }
  if (!RegExp(regexEmail).hasMatch(email)) {
    return TextZhLoginPage().errorEmail;
  }
  if (userName.length < 4 || userName.length > 10) {
    return TextZhLoginPage().errorNameLength;
  }

  String url = '/users/usernames/$userName';

  try {
    Response response = await dioPixivic.get(url);
    if (response.statusCode == 409) {
      return TextZhLoginPage().errorNameUsed;
    } else {
      return true;
    }
  } catch (e) {
    if (e.response.statusCode == 409) {
      return TextZhLoginPage().errorNameUsed;
    } else {
      return true;
    }
    return TextZhLoginPage().registerFailed;
  }
}

hasLogin() {
  if (prefs.getString('auth') == '') {
    BotToast.showSimpleNotification(title: TextZhLoginPage().notLogin);
    return false;
  } else {
    return true;
  }
}

changeAvatar() {}
