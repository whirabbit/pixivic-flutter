import 'dart:io';
import 'package:flutter/material.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';

import '../page/pic_detail_page.dart';
import '../data/texts.dart';
import '../data/common.dart';

uploadImageToSaucenao(File file, BuildContext context) async {
  TextZhUploadImage texts = TextZhUploadImage();
  String fileName = file.path.split('/').last;
  FormData data = FormData.fromMap({
    "file": await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    ),
  });
  Map<String, dynamic> queryParameters = {'output_type': '2'};
  CancelFunc loading = BotToast.showLoading();
  Dio dio = Dio();
  dio
      .post("https://saucenao.com/search.php",
          data: data, queryParameters: queryParameters)
      .then((response) async {
    loading();
    if (response.data['results'] == null)
      print('no result');
    else {
      double similarity =
          double.parse(response.data['results'][0]['header']['similarity']);
      String id = response.data['results'][0]['data']['pixiv_id'].toString();
      if (response.statusCode == 200) {
        if (similarity < 50)
          BotToast.showSimpleNotification(title: texts.similarityLow);
        else {
          Dio getIllust = Dio();
          print(response.data['results'][0]['header']['similarity']);
          print(response.data['results'][0]['data']['pixiv_id']);
          print(prefs.getString('auth') == '');
          Response illustResponse = await getIllust.get(
              'https://api.pixivic.com/illusts/$id',
              options: Options(
                  headers: prefs.getString('auth') == ''
                      ? {}
                      : {'authorization': prefs.getString('auth')}));
          if (illustResponse.statusCode == 200) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PicDetailPage(illustResponse.data['data']);
            }));
          } else {
            print(illustResponse.statusCode);
            print('on low error');
            BotToast.showSimpleNotification(
                title: illustResponse.data['meesage']);
          }
        }
      } else if (response.statusCode == 403) {
        BotToast.showSimpleNotification(title: texts.invalidKey);
      } else if (response.statusCode == 413) {
        BotToast.showSimpleNotification(title: texts.fileTooLarge);
      } else if (response.statusCode == 429) {
        if (response.data['header']['message'].contains('Daily'))
          BotToast.showSimpleNotification(title: texts.dailyLimit);
        else
          BotToast.showSimpleNotification(title: texts.shortLimit);
      }
    }
  }).catchError((Object error) {
    loading();
    print(error);
    print('on top error');
    BotToast.showSimpleNotification(title: error.toString());
  });
}
