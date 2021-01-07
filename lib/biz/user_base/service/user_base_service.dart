import 'package:injectable/injectable.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/http/client/user_base_rest_client.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/common/do/user_info.dart';
import 'package:bot_toast/bot_toast.dart';

@lazySingleton
class UserBaseService {
  final UserBaseRestClient _userBaseRestClient;

  UserBaseService(this._userBaseRestClient);

  processDioError(obj) {
    final res = (obj as DioError).response;
    BotToast.showSimpleNotification(title: res.statusMessage);
  }

  Future<UserInfo> queryUserLogin(String vid, String code, Map body) {
    return _userBaseRestClient
        .queryUserLoginInfo(vid, code, body)
        .then((value) {
      if (value.data != null) value.data = UserInfo.fromJson(value.data);
      return value.data as UserInfo;
    });
  }

  Future<String> queryUserRegisters(String vid, String code, Map body) {
    return _userBaseRestClient
        .queryUserRegistersInfo(vid, code, body)
        .then((value) {
      if (value.data != null) value.data = UserInfo.fromJson(value.data);
      BotToast.showSimpleNotification(title: TextZhLoginPage().registerSucceed);
      return value.data as String;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          processDioError(obj);
          break;
        default:
      }
    });
  }
}
