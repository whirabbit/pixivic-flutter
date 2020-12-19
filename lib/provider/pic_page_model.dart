import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_screenutil/screenutil.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/provider/page_switch.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/function/dio_client.dart';

class PicPageModel with ChangeNotifier {
  String picDate;
  String picMode;
  String artistId;
  String spotlightId;
  String userId;
  String collectionId;
  String searchKeywords;
  String url;
  String jsonMode;
  bool isManga = false;
  bool isScrollable = true;
  num relatedId;
  ValueChanged<bool> onPageScrolling;
  VoidCallback onPageTop;
  VoidCallback onPageStart;
  ValueChanged<double> betweenEdgeOfScroller;

  bool hasConnected = false;
  bool loadMoreAble = true;
  bool isScrolling = false;
  int currentPage = 1;
  List picList;
  List jsonList;
  List<int> onSelectedList;
  ScrollController scrollController;
  PageSwitchProvider indexProvider;
  //用于共享 context 给 indexProvider
  BuildContext context;

  PicPageModel(
      {this.context,
      this.picDate,
      this.picMode,
      this.artistId,
      this.spotlightId,
      this.userId,
      this.collectionId,
      this.searchKeywords,
      this.url,
      this.jsonMode,
      this.isManga = false,
      this.isScrollable = true,
      this.relatedId,
      this.onPageScrolling,
      this.onPageTop,
      this.onPageStart,
      this.betweenEdgeOfScroller}) {
    print("PicPageModel cteated and init");

    // 清空或者初始化长按的选择列表
    onSelectedList = [];

    // load home list cache list data if existed
    if (jsonMode == 'home' &&
        picMode == homePicModel &&
        picDate == homePicDate &&
        (!listEquals(homePicList, []))) {
      print("load home cache list data");
      scrollController =
          ScrollController(initialScrollOffset: homeScrollerPosition)
            ..addListener(_doWhileScrolling);
      picList = homePicList;
      currentPage = homeCurrentPage;
      jsonList = [];
    } else {
      scrollController = ScrollController(initialScrollOffset: 0.0)
        ..addListener(_doWhileScrolling);
      initAndLoadData();
    }

    indexProvider = Provider.of<PageSwitchProvider>(context, listen: false);

    notifyListeners();
  }

  @override
  dispose() {
    super.dispose();
    print("PicPage Model dispose");
    if (jsonMode == 'home' && picList != null) {
      homePicList = picList;
      homeCurrentPage = currentPage;
      homePicDate = picDate;
      homePicModel = picMode;
    }
    scrollController.removeListener(_doWhileScrolling);
    scrollController.dispose();
  }

  flipLikeState(int index) {
    picList[index]['isLiked'] = !picList[index]['isLiked'];
    notifyListeners();
  }

  saveListToHomePicList(int currentPage) {
    if (picList != null && jsonMode == 'home') {
      homePicList = picList;
      homeCurrentPage = currentPage;
    }
  }

  handlePicIndexToSelectedList(int index) {
    if (onSelectedList.contains(index))
      onSelectedList.remove(index);
    else {
      onSelectedList.add(index);
    }

    notifyListeners();
  }

  List outputPicIdList() {
    print('onSelectedList: $onSelectedList');
    if (onSelectedList.length > 0)
      return List.generate(onSelectedList.length,
          (index) => picList[onSelectedList[index]]['id']);
    else
      return [];
  }

  bool isInSelectMode() {
    return onSelectedList.length > 0 ? true : false;
  }

  bool isIndexInSelectedList(int index) => onSelectedList.contains(index);

  cleanSelectedList() {
    onSelectedList = [];
    notifyListeners();
  }

  _doWhileScrolling() {
    // FocusScope.of(context).unfocus();
    // 如果为主页面 picPage，则记录滑动位置、判断滑动
    if (jsonMode == 'home') {
      homeScrollerPosition = scrollController.position.extentBefore;
      // 保持记录scrollposition，原因为 dispose 时无法记录
      // 判断是否在滑动，以便隐藏底部控件
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!indexProvider.judgeScrolling) {
          indexProvider.changeScrolling(true);
        }
      }
      // 当页面平移时，底部导航栏需重新上浮
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (indexProvider.judgeScrolling) {
          indexProvider.changeScrolling(false);
        }
      }
    }

    // if (jsonMode == 'related') {
    //   double move = scrollController.position.extentBefore;
    //   if (move > 0 && move <= ScreenUtil().setHeight(450)) if (scrollController
    //           .position.userScrollDirection ==
    //       ScrollDirection.reverse)
    //     betweenEdgeOfScroller(move);
    //   else if (scrollController.position.userScrollDirection ==
    //       ScrollDirection.forward) betweenEdgeOfScroller(-move);
    // }

    if (jsonMode == 'artist' || jsonMode == 'userdetail') {
      if (scrollController.position.extentBefore == 0 &&
          scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
        onPageTop();
        print('on page top');
      }
      if (scrollController.position.extentBefore > 150 &&
          scrollController.position.extentBefore < 200 &&
          scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        onPageStart();
        print('on page start');
      }
    }

    // Auto Load
    // if ((scrollController.position.extentAfter < 1200) &&
    //     (currentPage < 30) &&
    //     loadMoreAble) loadData();
  }

  // 初始化以及加载数据
  initAndLoadData() async {
    hasConnected = false;
    currentPage = 1;
    picList = null;
    notifyListeners();

    getJsonList().then((value) {
      if (value != null) {
        picList = value;
      } else {
        hasConnected = true;
      }
      notifyListeners();
    }).catchError((error) {
      print('======================');
      print(error);
      print('======================');
      if (error.toString().contains('NoSuchMethodError')) picList = null;
      hasConnected = true;
    });
  }

  loadData() {
    print("Picpage Model: Load data start");
    loadMoreAble = false;
    currentPage++;
    print('current page is $currentPage');
    try {
      getJsonList(currentPage: currentPage).then((value) {
        // 如果不为空，则更新列表，且可继续加载
        if (value != null) {
          picList = picList + value;
          loadMoreAble = true;
          notifyListeners();
        } else {
          print("Picpage: Load data return end");
        }
      });
    } catch (err) {
      print('=========getJsonList==========');
      print(err);
      print('==============================');
      if (err.toString().contains('SocketException'))
        BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
      currentPage -= 1;
      loadMoreAble = true;
    }
  }

  getJsonList({int currentPage = 1}) async {
    // 获取所有的图片数据
    if (jsonMode == 'home') {
      url = '/ranks?page=$currentPage&date=$picDate&mode=$picMode&pageSize=10';
    } else if (jsonMode == 'search') {
      if (!isManga)
        url =
            '/illustrations?page=$currentPage&keyword=$searchKeywords&pageSize=10';
      else
        url =
            '/illustrations?page=$currentPage&keyword=$searchKeywords&pageSize=10';
    } else if (jsonMode == 'related') {
      url = '/illusts/$relatedId/related?page=$currentPage&pageSize=15';
    } else if (jsonMode == 'artist') {
      if (!isManga) {
        url =
            '/artists/$artistId/illusts/illust?page=$currentPage&pageSize=15&maxSanityLevel=10';
      } else {
        url =
            '/artists/$artistId/illusts/manga?page=$currentPage&pageSize=15&maxSanityLevel=10';
      }
    } else if (jsonMode == 'followed') {
      // this.loadMoreAble = false;
      if (!isManga) {
        url =
            '/users/$userId/followed/latest/illust?page=$currentPage&pageSize=10';
      } else {
        url =
            '/users/$userId/followed/latest/manga?page=$currentPage&pageSize=10';
      }
    } else if (jsonMode == 'bookmark') {
      if (!isManga) {
        url = '/users/$userId/bookmarked/illust?page=$currentPage&pageSize=10';
      } else {
        url = '/users/$userId/bookmarked/manga?page=$currentPage&pageSize=10';
      }
    } else if (jsonMode == 'spotlight') {
      // this.loadMoreAble = false;
      url = '/spotlights/$spotlightId/illustrations';
    } else if (jsonMode == 'history') {
      url =
          '/users/${prefs.getInt('id').toString()}/illustHistory?page=$currentPage&pageSize=10';
    } else if (jsonMode == 'oldhistory') {
      url =
          '/users/${prefs.getInt('id').toString()}/oldIllustHistory?page=$currentPage&pageSize=10';
    } else if (jsonMode == 'userdetail') {
      if (!isManga) {
        url = '/users/$userId/bookmarked/illust?page=$currentPage&pageSize=10';
      } else {
        url = '/users/$userId/bookmarked/manga?page=$currentPage&pageSize=10';
      }
    } else if (jsonMode == 'collection') {
      url =
          '/collections/$collectionId/illustrations?page=$currentPage&pageSize=10';
    }

    List list;

    try {
      Response response = await dioPixivic.get(url);
      // print(response.data['data']);
      list = response.data['data'];
    } catch (e) {
      if (e.response.statusCode == 400)
        BotToast.showSimpleNotification(title: '请登录后再重新加载画作');
      BotToast.showSimpleNotification(title: '获取画作信息失败，请检查网络');
    }

    return list;
  }
}
