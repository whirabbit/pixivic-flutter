import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:random_color/random_color.dart';

import '../data/common.dart';
import '../data/texts.dart';
import '../widget/papp_bar.dart';

class GuessLikePage extends StatefulWidget {
  @override
  _GuessLikePageState createState() => _GuessLikePageState();
}

class _GuessLikePageState extends State<GuessLikePage> {
  bool hasConnected = false;
  List picList;
  RandomColor _randomColor;
  TextZhGuessLikePage texts = TextZhGuessLikePage();

  @override
  void initState() {
    _getJsonList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(title: texts.title,),
      body: Container(),
    );
  }

  

  _getJsonList() async {
    String url =
        'https://api.pixivic.com/users/${prefs.getInt('id')}/recommendBookmarkIllusts';
    Map<String, String> headers = {'authorization': prefs.getString('auth')};
    try {
      Response response =
          await Dio().get(url, options: Options(headers: headers));
      picList = response.data['data'];
      print(picList[0]);
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
  }
}
