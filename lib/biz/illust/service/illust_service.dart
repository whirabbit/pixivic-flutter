import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:pixivic/http/client/illust_rest_client.dart';
import 'package:pixivic/http/client/rank_rest_client.dart';
import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/http/client/recommended_rest_client.dart';
import 'package:pixivic/http/client/search_rest_client.dart';
import 'package:pixivic/http/client/wallpaper_rest_client.dart';
import 'package:pixivic/common/do/bookmarked_user.dart';

@lazySingleton
class IllustService {
  final IllustRestClient _illustRestClient;
  final RankRestClient _rankRestClient;
  final SearchRestClient _searchRestClient;
  final RecommendedRestClient _recommendedRestClient;
  final WallpaperRestClient _wallpaperRestClient;

  IllustService(
      this._illustRestClient,
      this._rankRestClient,
      this._searchRestClient,
      this._recommendedRestClient,
      this._wallpaperRestClient);

  processIllustData(List data) {
    List<Illust> illustList = data.map((s) => Illust.fromJson(s)).toList();
    return illustList;
  }

  processBookmarkedUserData(List data) {
    List<BookmarkedUser> bookmarkedUserList =
        data.map((s) => BookmarkedUser.fromJson(s)).toList();
    return bookmarkedUserList;
  }

  Future<List<Illust>> queryIllustRank(
      String date, String mode, int page, int pageSize) {
    return _rankRestClient
        .queryIllustRankInfo(date, mode, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data;
    });
  }

  Future<List<Illust>> querySearch(String keyword, int page, int pageSize) {
    return _searchRestClient
        .querySearchListInfo(keyword, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data as List<Illust>;
    });
  }

//以图搜图
  Future<List<Illust>> querySearchForPictures(String imageUrl) {
    return _searchRestClient.querySearchForPicturesInfo(imageUrl).then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data as List<Illust>;
    });
  }

  //推荐收藏画作
  Future<List<Illust>> queryRecommendCollectIllust(int userId) {
    return _recommendedRestClient
        .queryRecommendCollectIllustInfo(userId)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data as List<Illust>;
    });
  }

  //Id查画作
  Future<Illust> querySearchIllustById(int illustId,
      {Function onReceiveProgress}) {
    return _illustRestClient
        .querySearchIllustByIdInfo(illustId, onReceiveProgress)
        .then((value) {
      if (value.data != null) value.data = Illust.fromJson(value.data);
      return value.data as Illust;
    }).catchError((Object obj) {
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          print(res.statusCode);
          BotToast.showSimpleNotification(title: res.data['message']);
          break;
        default:
          return false;
      }
    });
  }

//关联画作
  Future<List<Illust>> queryRelatedIllustList(
      num relatedId, int page, int pageSize) {
    return _illustRestClient
        .queryRelatedIllustListInfo(relatedId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data as List<Illust>;
    });
  }

//标签下画作列表

  Future<List<Illust>> queryIllustUnderTagList(
      int categotyId, int tagId, String type, double offset, int pageSize) {
    return _wallpaperRestClient
        .queryIllustUnderTagListInfo(categotyId, tagId, type, offset, pageSize)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value.data as List<Illust>;
    });
  }

  Future<List<BookmarkedUser>> queryUserOfCollectionIllustList(
      num userId, int page, int pageSize) {
    return _illustRestClient
        .queryUserOfCollectionIllustListInfo(userId, page, pageSize)
        .then((value) {
      if (value.data != null)
        value.data = processBookmarkedUserData(value.data);
      return value.data as List<BookmarkedUser>;
    });
  }
}
