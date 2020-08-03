import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';

import '../data/common.dart';
import '../data/texts.dart';
import '../widget/papp_bar.dart';

class GuessLikePage extends StatefulWidget {
  @override
  _GuessLikePageState createState() => _GuessLikePageState();
}

class _GuessLikePageState extends State<GuessLikePage> {
  bool hasConnected = false;
  List jsonList;
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
      jsonList = response.data['data'];
      print(jsonList[0]);
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
