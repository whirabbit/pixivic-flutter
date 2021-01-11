import 'package:dio/dio.dart';
// import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:pixivic/data/common.dart';

Dio dioPixivic;

initDioClient() {
  dioPixivic = Dio(BaseOptions(
      baseUrl: 'https://pix.ipv4.host',
      // baseUrl: 'https://dev.api.pixivic.com',
      connectTimeout: 150000,
      receiveTimeout: 150000,
      headers: prefs.getString('auth') == ''
          ? {'Content-Type': 'application/json'}
          : {
              'authorization': prefs.getString('auth'),
              'Content-Type': 'application/json'
            }));
  // dioPixivic.httpClientAdapter = Http2Adapter(
  //   ConnectionManager(
  //     idleTimeout: 10000,

  //     /// Ignore bad certificate
  //     onClientCreate: (_, clientSetting) =>
  //         clientSetting.onBadCertificate = (_) => true,
  //   ),
  // );
  dioPixivic.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
    print(options.uri);
    print(options.headers);
    print(options.data);
    return options;
  }, onResponse: (Response response) async {
    // print(response.data);
    // BotToast.showSimpleNotification(title: response.data['message']);
    // auth 更新时自动替换
    if (response.statusCode == 200 &&
        response.headers.map['authorization'] != null &&
        prefs.getString('auth') != response.headers.map['authorization'][0]) {
      prefs.setString('auth', response.headers.map['authorization'][0]);
    }
    return response;
  }, onError: (DioError e) async {
    if (e.response != null) {
      print('==== DioPixivic Catch ====');
      // print(e.response);
      print(e.response.statusCode);
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      if (e.response.data['message'] != '')
        BotToast.showSimpleNotification(title: e.response.data['message']);
      else if (e.response.statusCode == 400)
        BotToast.showSimpleNotification(title: '遇到了 400 错误');
      else if (e.response.statusCode == 500) {
        print('500 error');
      } else if (e.response.statusCode == 401 || e.response.statusCode == 403) {
        BotToast.showSimpleNotification(title: '登陆已失效，请重新登陆');
      }
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      if (e.message != '') BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
    }
    return e;
  }));
}
