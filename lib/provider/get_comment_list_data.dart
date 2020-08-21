import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
class GetCommentProvider with ChangeNotifier{
  List _commentsList;
  List get commentList=>_commentsList;
  loadComments(int illustId) async {
    String url = 'https://api.pixivic.com/illusts/${illustId}/comments';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.statusCode == 200 && response.data['data'] != null) {
      // print(response.data);

      _commentsList = response.data['data'];
        notifyListeners();
    } else if (response.statusCode == 200 && response.data['data'] == null) {
      print('comments: null but 200');
    } else {
      BotToast.showSimpleNotification(title: response.data['message']);
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}