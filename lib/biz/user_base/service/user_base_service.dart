import 'package:injectable/injectable.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/verification_code.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/http/client/user_base_rest_client.dart';
import 'package:pixivic/common/do/user_info.dart';


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
          final res = (obj as DioError).response;
          if (res.statusCode == 200) {
            // 切换至login界面，并给出提示
            BotToast.showSimpleNotification(
                title: TextZhLoginPage().registerSucceed);
          } else {
            // isLogin = false;
            print(res.data['message']);
            BotToast.showSimpleNotification(title: res.data['message']);
          }
          break;
        default:
      }
    });
  }

  Future<VerificationCode> queryVerificationCode() {
    return _userBaseRestClient.queryVerificationCodeInfo().then((value) {
      if (value.data != null)
        value.data = VerificationCode.fromJson(value.data);
      return value.data as VerificationCode;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          BotToast.showSimpleNotification(
              title: TextZhLoginPage().errorGetVerificationCode);
          break;
        default:
      }
    });
  }

  Future<Result> queryResetPasswordByEmail(String emailAddr) {
    return _userBaseRestClient
        .queryResetPasswordByEmailInfo(emailAddr)
        .then((value) {
      return value;
    });
  }

  Future queryVerifyUserNameIsAvailable(String userName) {
    return _userBaseRestClient
        .queryVerifyUserNameIsAvailableInfo(userName)
        .then((value) {
      return value;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          if (res.statusCode == 409) {
            return TextZhLoginPage().errorNameUsed;
          } else {
            return true;
          }
          break;
        default:
          return TextZhLoginPage().registerFailed;
      }
    });
  }

  Future<UserInfo> querySearchUserInfo(int userId) {
    return _userBaseRestClient.querySearchUserInfo(userId).then((value) {
      value.data = UserInfo.fromJson(value.data);
      return value.data;
    });
  }
}
