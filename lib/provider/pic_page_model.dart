import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';

import 'package:requests/requests.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'package:pixivic/provider/page_switch.dart';
import 'package:pixivic/data/common.dart';

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

  PicPageModel({
    this.context,
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
  }) {
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

    if (jsonMode == 'related' ||
        jsonMode == 'artist' ||
        jsonMode == 'userdetail') {
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
          if (value != null) {
            picList = picList + value;
            loadMoreAble = true;
            notifyListeners();
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
  }

  // 初始化以及加载数据
  initAndLoadData() async {
    hasConnected = false;
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
      this.loadMoreAble = false;
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
      this.loadMoreAble = false;
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
            'https://api.pixivic.com/users/$userId/bookmarked/illust?page=$currentPage&pageSize=30';
      } else {
        url =
            'https://api.pixivic.com/users/$userId/manga?page=$currentPage&pageSize=30';
      }
    } else if (jsonMode == 'collection') {
      url =
          'https://api.pixivic.com/collections/$collectionId/illustrations?page=$currentPage&pagesize=10';
    }

    // TODO: Dio 重做后更换为Dio
    try {
      if (prefs.getString('auth') == '') {
        var requests = await Requests.get(url);
        jsonList = jsonDecode(requests.content())['data'];
        print(requests.statusCode);
        if (requests.statusCode == 400)
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
      return jsonList;
    } catch (error) {
      print('=========getJsonList==========');
      print(error);
      print('==============================');
      if (error.toString().contains('SocketException'))
        BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
    }
  }
}
