import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';

import '../widget/papp_bar.dart';
import '../data/common.dart';
import '../data/texts.dart';

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

addIllustToAlbumn(int illustId, int albumnId) async {
  String url = 'https://api.pixivic.com/collections/${albumnId}/illustrations';
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

addNewAlbumn(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return NewAlbumn();
  }));
}

class NewAlbumn extends StatelessWidget {
  TextZhAlbumn texts = TextZhAlbumn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(title: texts.newAlbumnTitle),
      body: Container(),
    );
  }
}

showAddNewAlbumnDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return Container();
      });
}

showAddTagBottomSheet() {}
