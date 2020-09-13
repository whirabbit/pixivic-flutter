import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';

class GetCommentProvider with ChangeNotifier {
  List commentList;

  loadComments(int illustId, {int page = 1}) async {
    String url =
        'https://api.pixivic.com/illusts/$illustId/comments?page=$page&pageSize=10';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.statusCode == 200 && response.data['data'] != null) {
      // print(response.data);
      commentList = response.data['data'];
      notifyListeners();
      return commentList;
    } else if (response.statusCode == 200 && response.data['data'] == null) {
      commentList = [];
      print('comments: null but 200');

      return commentList;
    } else {
      BotToast.showSimpleNotification(title: response.data['message']);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
