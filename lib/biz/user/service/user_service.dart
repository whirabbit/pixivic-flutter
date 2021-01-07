import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/http/client/user_rest_client.dart';
import 'package:bot_toast/bot_toast.dart';

@lazySingleton
class UserService {
  final UserRestClient _userRestClient;

  UserService(this._userRestClient);

  processIllustData(List data) {
    List<Illust> illusList = data.map((s) => Illust.fromJson(s)).toList();
    return illusList;
  }

  processArtistData(List data) {
    List<Artist> artistList = data.map((s) => Artist.fromJson(s)).toList();
    return artistList;
  }

  processDioError(obj) {
    final res = (obj as DioError).response;
    if (res.statusCode == 400)
      BotToast.showSimpleNotification(title: '请登录后再重新加载画作');
    BotToast.showSimpleNotification(title: '获取画作信息失败，请检查网络');
  }

  Future<List<Artist>> queryFollowedWithRecentlyIllusts(
      int illustId, int page, int pageSize) {
    return _userRestClient
        .queryFollowedWithRecentlyIllustsInfo(illustId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processArtistData(value.data);
      return value.data;
    });
  }

//画师最新画作
  Future<List<Illust>> queryUserFollowedLatestIllustList(
      int userId, String type, int page, int pageSize) {
    return _userRestClient
        .queryUserFollowedLatestIllustListInfo(userId, type, page, pageSize)
        .then((value) {
      if (value.data != null)
        value.data = processIllustData(
          value.data,
        );
      return value.data;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          processDioError(obj);
          break;
        default:
      }
    });
  }

//获取收藏的画作
  Future<List<Illust>> queryUserCollectIllustList(
      int userId, String type, int page, int pageSize) {
    return _userRestClient
        .queryUserCollectIllustListInfo(userId, type, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          processDioError(obj);
          break;
        default:
      }
    });
  }

  Future<List<Illust>> queryHistoryList(String userId, int page, int pageSize) {
    return _userRestClient
        .queryHistoryListInfo(userId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          processDioError(obj);
          break;
        default:
      }
    });
  }

  Future<List<Illust>> queryOldHistoryList(
      String userId, int page, int pageSize) {
    return _userRestClient
        .queryOldHistoryListInfo(userId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          processDioError(obj);
          break;
        default:
      }
    });
  }

  Future<List<Illust>> queryCollectionList(
      int collectionId, int page, int pageSize) {
    return _userRestClient
        .queryCollectionListInfo(collectionId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data;
    });
  }
}
