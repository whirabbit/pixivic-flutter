/* 
fxt0706 2020-08-20
description: 文件封装了与画集有关的相关功能
*/
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/papp_bar.dart';
import '../data/common.dart';
import '../data/texts.dart';

// 获取当前登录用户的画集列表
getAlbumList() async {
  List albumList;
  String url =
      'https://api.pixivic.com/users/${prefs.getInt('id')}/collections';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  try {
    Response response =
        await Dio().get(url, options: Options(headers: headers));
    // print(response.data['data']);
    albumList = response.data['data'];
    // print('The user album list:\n$albumList');
    return albumList;
  } on DioError catch (e) {
    if (e.response != null) {
      BotToast.showSimpleNotification(title: e.response.data['message']);
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return null;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
      return null;
    }
  }
}

// 将选中画作添加到指定的画集中
addIllustToAlbumn(int illustId, int albumnId) async {
  String url = 'https://api.pixivic.com/collections/$albumnId/illustrations';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  Map<String, String> data = {'illust_id': illustId.toString()};
  try {
    Response response = await Dio().post(url,
        options: Options(
          headers: headers,
        ),
        data: data);
    BotToast.showSimpleNotification(title: response.data['message']);
  } on DioError catch (e) {
    if (e.response != null) {
      BotToast.showSimpleNotification(title: e.response.data['message']);
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return null;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
      return null;
    }
  }
}

showAddNewAlbumnDialog(BuildContext context) {
  TextEditingController title = TextEditingController();
  TextEditingController caption = TextEditingController();
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: ScreenUtil().setWidth(260),
            height: ScreenUtil().setHeight(250),
            child: Column(
              children: [
                Container(
                    alignment: Alignment.center,
                    child: Text(
                      '新建画集',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.orangeAccent),
                    )),
                TextField(
                  controller: title,
                  decoration:
                      InputDecoration(isDense: true, hintText: '输入画集名称'),
                ),
                TextField(
                  controller: caption,
                  decoration:
                      InputDecoration(isDense: true, hintText: '输入画集介绍'),
                ),
              ],
            ),
          ),
        );
      });
}

showAddTagBottomSheet() {}
