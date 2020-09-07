import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
// import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';

import '../data/common.dart';


class CollectionModel with ChangeNotifier {
  /* 画集 model 处理两块内容，展示画集卡片的列表(Viewer)，以及打开画集后的列表(Collection)  */
  int currentViewerPage;
  bool onVierwerEdit;
  bool onViewerLoad;
  bool onViewerBottom;
  List viewerList;

  int currentCollectionPage;
  bool onCollectionEdit;
  bool onCollectionLoad;
  bool onCollectionBottom;
  List collectionList;

  initData() {
    currentViewerPage = 1;
    onVierwerEdit = false;
    onViewerLoad = false;
    onViewerBottom = false;
    viewerList = [];

    currentCollectionPage = 1;
    onCollectionEdit = false;
    onCollectionLoad = false;
    onCollectionBottom = false;
    collectionList = [];
  }

  resetViewer() {
    currentViewerPage = 1;
    onVierwerEdit = false;
    onViewerLoad = false;
    viewerList = [];
  }

  getViewerJsonList() async {
    onViewerLoad = true;
    notifyListeners();

    String url =
        'https://api.pixivic.com/users/${prefs.getInt('id')}/collections?page=$currentViewerPage&pagesize=10';
    Map<String, String> headers = {'authorization': prefs.getString('auth')};

    try {
      Response response =
          await Dio().get(url, options: Options(headers: headers));
      if (response.data['data'] != null) {
        viewerList = viewerList + response.data['data'];
      } else if(response.data['data'] == null) {
        onViewerBottom = true;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        BotToast.showSimpleNotification(title: e.response.data['message']);
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        BotToast.showSimpleNotification(title: e.message);
        print(e.request);
        print(e.message);
      }
    }
    onViewerLoad = false;
    notifyListeners();
  }

  getCollectionJsonList() {}
}
