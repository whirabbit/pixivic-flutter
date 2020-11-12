import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:pixivic/data/common.dart';

Dio dioPixivic;

initDioClient() {
  dioPixivic = Dio(BaseOptions(
      baseUrl: 'https://api.pixivic.com',
      connectTimeout: 150000,
      receiveTimeout: 150000,
      headers: prefs.getString('auth') == ''
          ? {'Content-Type': 'application/json'}
          : {
              'authorization': prefs.getString('auth'),
              'Content-Type': 'application/json'
            }));

  dioPixivic.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
    print(options.uri);
    print(options.headers);
    return options;
  }, onResponse: (Response response) async {
    print(response.data);
    BotToast.showSimpleNotification(title: response.data['message']);
    return response;
  }, onError: (DioError e) async {
    if (e.response != null) {
      BotToast.showSimpleNotification(title: e.response.data['message']);
      print(e.response.statusCode);
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return e.response;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
      return e;
    }
  }));
}
