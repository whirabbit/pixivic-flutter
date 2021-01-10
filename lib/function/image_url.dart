import 'package:dio/dio.dart';

import 'package:pixivic/data/common.dart';
import 'package:pixivic/function/dio_client.dart';

String vipUrl = '';

String imageUrl(String url, String mode) {
  print(mode);
  String result;
  if (prefs.getInt('permissionLevel') == 3 &&
      vipUrl != '' &&
      mode == 'original') {
    result = url.replaceAll('https://i.pximg.net', vipUrl);
    result = result + '?authorization=${prefs.getString('auth')}';
  } else if (!prefs.getBool('isOnPixivicServer')) {
    result = url;
  } else if (prefs.getBool('isOnPixivicServer')) {
    result = url.replaceAll('https://i.pximg.net', 'https://img.pixivic.net');
    result = result + '?authorization=${prefs.getString('auth')}';
  } else {
    result = url;
  }
  print(result);
  return result;
}

Map imageHeader(String mode) {
  Map<String, String> result;
  if (prefs.getInt('permissionLevel') == 3 &&
      vipUrl != '' &&
      mode == 'original') {
    result = {'authorization': prefs.getString('auth')};
  } else if (!prefs.getBool('isOnPixivicServer')) {
    result = {'Referer': 'https://app-api.pixiv.net'};
  } else if (prefs.getBool('isOnPixivicServer') && isLogin) {
    result = {'authorization': prefs.getString('auth')};
  } else if (prefs.getBool('isOnPixivicServer') && !isLogin) {
    result = {};
  } else {
    result = {'Referer': 'https://app-api.pixiv.net'};
  }
  print(result);
  return result;
}

void getVipUrl() async {
  if (prefs.getInt('permissionLevel') == 3) {
    try {
      print(prefs.getInt('permissionLevel'));
      Response response = await dioPixivic.get('/vipProxyServer');
      print('===============VIP===============');
      vipUrl = response.data['data'][0]['serverAddress'];
      print(vipUrl);
    } catch (e) {}
  }
}
