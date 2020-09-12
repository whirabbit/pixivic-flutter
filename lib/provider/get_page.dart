import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:requests/requests.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
import 'package:pixivic/provider/page_switch.dart';

import '../data/common.dart';

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
  bool isScrollable = true;
  num relatedId;
  ValueChanged<bool> onPageScrolling;
  VoidCallback onPageTop;
  VoidCallback onPageStart;
  bool hasConnected = false;
  bool loadMoreAble = true;
  bool isScrolling = false;
  int currentPage = 1;
  List picList;
  List jsonList;
  ScrollController scrollController;
  BuildContext context;

  GetPageProvider({this.jsonMode}) {
    print("控制器初始化");
    scrollController = ScrollController(
        initialScrollOffset: jsonMode == 'home' ? homeScrollerPosition : 0.0)
      ..addListener(_doWhileScrolling);
    //加载缓存数据
    if (this.jsonMode == 'home' && (!listEquals(homePicList, []))) {
      print("加载缓存数据");
      picList = homePicList;
      currentPage = homeCurrentPage;
      jsonList = [];
    }
  }

  homePage({
    @required String picDate,
    @required String picMode,
  }) {
    if (this.picDate != null &&
        (this.picDate != picDate || this.picMode != picMode)) {
      //重新刷新页面所有缓存重置
      currentPage = 1;
      homeCurrentPage = 1;
      homePicList = [];
      homeScrollerPosition = 0;
      scrollController = ScrollController(
          initialScrollOffset: jsonMode == 'home' ? homeScrollerPosition : 0.0)
        ..addListener(_doWhileScrolling);
      this.picList = null;
    }

    this.jsonMode = 'home';
    this.picDate = picDate;
    this.picMode = picMode;
  }

  void searchPage(
      {@required String searchKeywords, @required bool searchManga}) {
    if (this.searchKeywords != searchKeywords) {
      this.picList = null;
    }
    this.jsonMode = 'search';
    this.searchKeywords = searchKeywords;
    this.isManga = searchManga;
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
  }

  void followedPage({@required String userId, @required bool isManga}) {
    this.jsonMode = 'followed';
    this.userId = userId;
    this.isManga = isManga;
  }

  void bookmarkPage({@required String userId, @required bool isManga}) {
    this.jsonMode = 'bookmark';
    this.userId = userId;
    this.isManga = isManga;
  }

  void spotlightPage({@required String spotlightId}) {
    this.jsonMode = 'spotlight';
    this.spotlightId = spotlightId;
  }

  void historyPage() {
    this.jsonMode = 'history';
  }

  void oldHistoryPage() {
    this.jsonMode = 'oldhistory';
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
  }

  //标记方法
  void flipLikeState(int index) {
    picList[index]['isLiked'] = !picList[index]['isLiked'];
    notifyListeners();
  }

  // TODO: 当退出 home 模式的 PicPage 时，进行 homePicList 的保存
  void saveListToHomePicList(int currentPage) {
    if (picList != null && jsonMode == 'home') {
      homePicList = picList;
      homeCurrentPage = currentPage;
    }
  }

  collectionPage({@required String collectionId}) {
    this.collectionId = collectionId;
    getJsonList();
  }

  _doWhileScrolling() {
//    print("滑出ViewPort顶部的长度"+scrollController.position.extentBefore.toString());
//    print("ViewPort内部长度"+scrollController.position.extentInside.toString());
//      print("测量"+scrollController.position.extentAfter.toString());
//    FocusScope.of(context).unfocus();
    // 如果为主页面 picPage，则记录滑动位置、判断滑动
    if (jsonMode == 'home') {
      homeScrollerPosition = scrollController
          .position.extentBefore; // 保持记录scrollposition，原因为dispose时无法记录
      PageSwitchProvider indexProvider =
          Provider.of<PageSwitchProvider>(context, listen: false);
      // 判断是否在滑动，以便隐藏底部控件
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!indexProvider.judgeScrolling) {
          indexProvider.changeScrolling(true);
//          isScrolling = true;
//          widget.onPageScrolling(isScrolling);
        }
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        //显示
        if (indexProvider.judgeScrolling) {
          indexProvider.changeScrolling(false);
//          isScrolling = false;
//          widget.onPageScrolling(isScrolling);
        }
      }
    }

//    if (widget.jsonMode == 'related' ||
//        widget.jsonMode == 'artist' ||
//        widget.jsonMode == 'userdetail') {
//      if (scrollController.position.extentBefore == 0 &&
//          scrollController.position.userScrollDirection ==
//              ScrollDirection.forward) {
//        widget.onPageTop();
//        print('on page top');
//      }
//      if (scrollController.position.extentBefore > 150 &&
//          scrollController.position.extentBefore < 200 &&
//          scrollController.position.userScrollDirection ==
//              ScrollDirection.reverse) {
//        widget.onPageStart();
//        print('on page start');
//      }
//    }

    // Auto Load
    if ((scrollController.position.extentAfter < 1200) &&
        (currentPage < 30) &&
        loadMoreAble) {
      print("Picpage: Load Data");
      loadMoreAble = false;
      currentPage++;
      print('current page is $currentPage');
      try {
        getJsonList(currentPage: currentPage, loadMoreAble: loadMoreAble)
            .then((value) {
          if (value.length != 0) {
            loadMoreAble = true;
          }
        });
      } catch (err) {
        print('=========getJsonList==========');
        print(err);
        print('==============================');
        if (err.toString().contains('SocketException'))
          BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
        loadMoreAble = true;
      }
    }
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
    // TODO: 当 home 模式时，查看是否有 list 和 page 缓存，有的话则重载，而非重新加载
    // if(jsonMode == 'home' && currentPage < homeCurrentPage) {
    //   picList = homePicList;
    // } else {}
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
    print("providerDispose");
    if (jsonMode == 'home' && picList != null) {
      homePicList = picList;
      homeCurrentPage = currentPage;
    }
    picList = [];
    jsonList = null;
    scrollController.removeListener(_doWhileScrolling);
    scrollController.dispose();
  }
}
