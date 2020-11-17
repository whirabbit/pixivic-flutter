import 'dart:io';
import 'package:flutter/material.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../page/pic_detail_page.dart';
import '../data/texts.dart';

uploadImageToSaucenao(File file, BuildContext context) async {
  TextZhUploadImage texts = TextZhUploadImage();
  Response response;
  Response illustResponse;
  CancelFunc cancelLoading;

  String fileName = file.path.split('/').last;
  FormData data = FormData.fromMap({
    "file": await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    ),
  });
  Map<String, dynamic> queryParameters = {'output_type': '2'};

  try {
    cancelLoading = BotToast.showLoading();
    Dio dio = Dio();
    response = await dio.post("https://saucenao.com/search.php",
        data: data, queryParameters: queryParameters);
    cancelLoading();
    if (response.data['results'] == null) {
      print('no result found');
      BotToast.showSimpleNotification(title: texts.similarityLow);
      return false;
    } else {
      if (response.statusCode == 200) {
        double similarity =
            double.parse(response.data['results'][0]['header']['similarity']);
        String id = response.data['results'][0]['data']['pixiv_id'].toString();
        String extUrl;
        response.data['results'][0]['data']['ext_urls'] != null
            ? extUrl =
                response.data['results'][0]['data']['ext_urls'][0].toString()
            : extUrl = null;

        print(similarity);
        print(id);
        print(extUrl);

        if (similarity < 50) {
          BotToast.showSimpleNotification(title: texts.similarityLow);
          return false;
        } else if (id != 'null') {
          try {
            illustResponse = await dioPixivic.get(
              '/illusts/$id',
            );
            if (illustResponse.statusCode == 200) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PicDetailPage(illustResponse.data['data']);
              }));
              return true;
            }
          } catch (e) {
            print(e.response.statusCode);
            print('on low error');
            BotToast.showSimpleNotification(
                title: illustResponse.data['meesage']);
            return false;
          }
        } else if (id == 'null' && extUrl != null) {
          BotToast.showSimpleNotification(title: texts.noImageButUrl);
          if (await canLaunch(extUrl)) {
            await launch(extUrl);
          } else {
            throw 'Could not launch $extUrl';
          }
        } else {
          BotToast.showSimpleNotification(title: texts.similarityLow);
          return false;
        }
      }
    }
  } catch (e) {
    cancelLoading();
    if (e is DioError)
      BotToast.showSimpleNotification(title: e.response.data['message']);
    if (e.response.statusCode == 403) {
      BotToast.showSimpleNotification(title: texts.invalidKey);
      return false;
    } else if (e.response.statusCode == 413) {
      BotToast.showSimpleNotification(title: texts.fileTooLarge);
      return false;
    } else if (e.response.statusCode == 429) {
      if (response.data['header']['message'].contains('Daily'))
        BotToast.showSimpleNotification(title: texts.dailyLimit);
      else
        BotToast.showSimpleNotification(title: texts.shortLimit);
      return false;
    } else
      BotToast.showSimpleNotification(title: e.toString());
    return false;
  }
}
