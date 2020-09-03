import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:requests/requests.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:pixivic/data/common.dart';

class GetPageProvider with ChangeNotifier {
  String picDate;
  String picMode;
  String artistId;
  String spotlightId;
  String userId;
  String collectionId;
  String searchKeywords;
  String url;
  String jsonMode;
  bool isManga;
  bool isScrollable;
  int homeCurrentPage;
  num relatedId;
  ValueChanged<bool> onPageScrolling;
  VoidCallback onPageTop;
  VoidCallback onPageStart;

  List picList = [];

  List jsonList;

  homePage({
    @required String picDate,
    @required String picMode,
  }) {
    //加载动画
    if (this.picDate != picDate || this.picMode != picMode) {
      this.jsonList = null;
    }

    this.jsonMode = 'home';
    this.picDate = picDate;
    this.picMode = picMode;
  }

  void searchPage(
      {@required String searchKeywords, @required bool searchManga}) {
    this.jsonMode = 'search';
    this.searchKeywords = searchKeywords;
    this.isManga = searchManga;

//    getJsonList();
  }

  void relatedPage(
      {@required num relatedId,
      @required VoidCallback onTopOfPicpage,
      @required VoidCallback onStartOfPicpage}) {
    this.jsonMode = 'related';
    this.relatedId = relatedId;
    this.onPageTop = onTopOfPicpage;
    this.onPageStart = onStartOfPicpage;
    this.isScrollable = true;
  }

  void artistPage(
      {@required String artistId,
      @required bool isManga,
      @required VoidCallback onTopOfPicpage,
      @required VoidCallback onStartOfPicpage}) {
    this.jsonMode = 'artist';
    this.artistId = artistId;
    this.isManga = isManga;
    this.onPageTop = onTopOfPicpage;
    this.onPageStart = onStartOfPicpage;
//    getJsonList();
  }

  void followedPage({@required String userId, @required bool isManga}) {
    this.jsonMode = 'followed';
    this.userId = userId;
    this.isManga = isManga;
//    getJsonList();
  }

  void bookmarkPage({@required String userId, @required bool isManga}) {
    this.jsonMode = 'bookmark';
    this.userId = userId;
    this.isManga = isManga;
//    getJsonList();
  }

  void spotlightPage({@required String spotlightId}) {
    this.jsonMode = 'spotlight';
    this.spotlightId = spotlightId;
//    getJsonList();
  }

  void historyPage() {
    this.jsonMode = 'history';
//    getJsonList();
  }

  void oldHistoryPage() {
    this.jsonMode = 'oldhistory';
//    getJsonList();
  }

  void userdetailPage(
      {@required String userId,
      @required bool isManga,
      @required VoidCallback onTopOfPicpage,
      @required VoidCallback onStartOfPicpage}) {
    this.jsonMode = 'userdetail';
    this.userId = userId;
    this.isManga = isManga;
    this.onPageTop = onTopOfPicpage;
    this.onPageStart = onStartOfPicpage;
    getJsonList();
  }

  //标记方法
  void markFun(index) {
    picList[index]['isLiked'] = !picList[index]['isLiked'];
    notifyListeners();
  }

  //标记方法
  void flipLikeState(int index) {
    picList[index]['isLiked'] = !picList[index]['isLiked'];
    notifyListeners();
  }

  collectionPage({@required String collectionId}) {
    this.collectionId = collectionId;
    getJsonList();
  }

  getJsonList({bool loadMoreAble, int currentPage = 1}) async {
    // 获取所有的图片数据

    if (jsonMode == 'home') {
      url =
          'https://api.pixivic.com/ranks?page=$currentPage&date=$picDate&mode=$picMode&pageSize=30';
    } else if (jsonMode == 'search') {
      if (!isManga)
        url =
            'https://api.pixivic.com/illustrations?page=$currentPage&keyword=$searchKeywords&pageSize=30';
      else
        url =
            'https://api.pixivic.com/illustrations?page=$currentPage&keyword=$searchKeywords&pageSize=30';
    } else if (jsonMode == 'related') {
      url =
          'https://api.pixivic.com/illusts/$relatedId/related?page=$currentPage&pageSize=30';
    } else if (jsonMode == 'artist') {
      if (!isManga) {
        url =
            'https://api.pixivic.com/artists/$artistId/illusts/illust?page=$currentPage&pageSize=30&maxSanityLevel=10';
      } else {
        url =
            'https://api.pixivic.com/artists/$artistId/illusts/manga?page=$currentPage&pageSize=30&maxSanityLevel=10';
      }
    } else if (jsonMode == 'followed') {
      loadMoreAble = false;
      if (!isManga) {
        url =
            'https://api.pixivic.com/users/$userId/followed/latest/illust?page=$currentPage&pageSize=30';
      } else {
        url =
            'https://api.pixivic.com/users/$userId/followed/latest/manga?page=$currentPage&pageSize=30';
      }
    } else if (jsonMode == 'bookmark') {
      if (!isManga) {
        url =
            'https://api.pixivic.com/users/$userId/bookmarked/illust?page=$currentPage&pageSize=30';
      } else {
        url =
            'https://api.pixivic.com/users/$userId/bookmarked/manga?page=$currentPage&pageSize=30';
      }
    } else if (jsonMode == 'spotlight') {
      loadMoreAble = false;
      url = 'https://api.pixivic.com/spotlights/$spotlightId/illustrations';
    } else if (jsonMode == 'history') {
      url =
          'https://api.pixivic.com/users/${prefs.getInt('id').toString()}/illustHistory?page=$currentPage&pageSize=30';
    } else if (jsonMode == 'oldhistory') {
      url =
          'https://api.pixivic.com/users/${prefs.getInt('id').toString()}/oldIllustHistory?page=$currentPage&pageSize=30';
    } else if (jsonMode == 'userdetail') {
      if (!isManga) {
        url =
            'https://api.pixivic.com/users/$userId/bookmarked/illust?page=1&pageSize=30';
      } else {
        url = 'https://api.pixivic.com/users/$userId/manga?page=1&pageSize=30';
      }
    } else if (jsonMode == 'collection') {
      url =
          'https://api.pixivic.com/collections/$collectionId/illustrations?page=$currentPage&pagesize=10';
    }

    try {
      if (prefs.getString('auth') == '') {
        var requests = await Requests.get(url);
        jsonList = jsonDecode(requests.content())['data'];
        print(requests.statusCode);
//        print(requests.content());
        if (requests.statusCode == 401)
          BotToast.showSimpleNotification(title: '请登录后再重新加载画作');
      } else {
        Map<String, String> headers = {
          'authorization': prefs.getString('auth')
        };
        var requests = await Requests.get(url, headers: headers);
        // print(requests.content());
        // requests.raiseForStatus();
        jsonList = jsonDecode(requests.content())['data'];
      }
      if (jsonList == null) {
        jsonList = [];
      }
      notifyListeners();
      return jsonList;
    } catch (error) {
      print('=========getJsonList==========');
      print(error);
      print('==============================');
      if (error.toString().contains('SocketException'))
        BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
