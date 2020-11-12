import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:bot_toast/bot_toast.dart';
import 'package:requests/requests.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import '../data/common.dart';
import '../data/texts.dart';
import 'package:pixivic/provider/collection_model.dart';
import 'package:pixivic/function/dio_client.dart';

// identity.dart 文件包含与用户身份验证相关的所有方法，例如登录，验证 auth 是否过期，注册等等

// 缺少刷新流程
login(BuildContext context, String userName, String pwd,
    String verificationCode, String verificationInput,
    {String widgetFrom}) async {
  String url =
      'https://api.pixivic.com/users/token?vid=$verificationCode&value=$verificationInput';
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
    print(data);
    prefs.setInt('id', data['id']);
    prefs.setString('name', data['username']);
    prefs.setString('email', data['email']);
    prefs.setString('avatarLink',
        'https://static.pixivic.net/avatar/299x299/${data['id']}.jpg');
    if (data['signature'] != null)
      prefs.setString('signature', data['signature']);
    if (data['location'] != null) prefs.setString('location', data['location']);
    prefs.setInt('star', data['star']);
    prefs.setBool('isBindQQ', data['isBindQQ']);
    prefs.setBool('isCheckEmail', data['isCheckEmail']);
    isLogin = true;
    BotToast.showSimpleNotification(title: TextZhLoginPage().loginSucceed);
    print(newPageKey);
    print(userPageKey);
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
    Provider.of<CollectionUserDataModel>(context, listen: false);
    initDioClient();
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
  prefs.setString('auth', '');
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

checkAuth() async {
  String authStored = prefs.getString('auth');
  if (authStored == null || authStored == '')
    return false;
  else {
    String url =
        'https://api.pixivic.com/users/${prefs.getInt('id').toString()}/isBindQQ';
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'authorization': authStored
    };
    var client = http.Client();
    var response = await client.get(
      url,
      headers: header,
    );
    // print(response.statusCode);
    // Map data = jsonDecode(
    //     utf8.decode(response.bodyBytes, allowMalformed: true));
    // print(data);
    // print(response.headers['authorization']);
    if (response.statusCode == 200) {
      if (response.headers['authorization'] != null)
        prefs.setString('auth', response.headers['authorization']);
      return true;
    } else if (response.statusCode == 401 || response.statusCode == 500) {
      return false;
    }
  }
}

register(String userName, String pwd, String pwdRepeat, String verificationCode,
    String verificationInput, String emailInput) async {
  // 检查用户名和邮箱，密码（新建邮箱controller)
  String url =
      'https://api.pixivic.com/users/?vid=$verificationCode&value=$verificationInput';
  Map<String, String> body = {
    'username': userName,
    'email': emailInput,
    'password': pwd,
  };
  print(body);
  var response = await Requests.post(url,
      body: body, bodyEncoding: RequestBodyEncoding.JSON);
  if (response.statusCode == 200) {
    // 切换至login界面，并给出提示
    BotToast.showSimpleNotification(title: TextZhLoginPage().registerSucceed);
  } else {
    // isLogin = false;
    print(response.content());
    BotToast.showSimpleNotification(
        title: jsonDecode(response.content())['message']);
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

  String url = 'https://api.pixivic.com/users/usernames/$userName';
  try {
    var r = await Requests.get(url);
    if (r.statusCode == 409) {
      return TextZhLoginPage().errorNameUsed;
    } else {
      return true;
    }
  } catch (e) {
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
