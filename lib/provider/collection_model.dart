import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
// import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:pixivic/data/common.dart';

class CollectionUiModel with ChangeNotifier {
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
      } else if (response.data['data'] == null) {
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

class NewCollectionParameterModel with ChangeNotifier {
  bool _isPublic = true;
  bool _isSexy = false;
  bool _allowComment = true;
  List _tags = [];
  List _tagsAdvice = [];

  bool get isPublic => _isPublic;
  bool get isSexy => _isSexy;
  bool get allowComment => _allowComment;
  List get tags => _tags;
  List get tagsAdvice => _tagsAdvice;

  public(bool result) {
    _isPublic = result;
    notifyListeners();
  }

  sexy(bool result) {
    _isSexy = result;
    notifyListeners();
  }

  comment(bool result) {
    _allowComment = result;
    notifyListeners();
  }

  cleanTags() {
    _tags = [];
    // notifyListeners();
  }

  clearTagAdvice() {
    _tagsAdvice = [];
    notifyListeners();
  }

  getTagAdvice(String keywords) async {
    _tagsAdvice = [
      {'tagName': keywords}
    ];
    notifyListeners();
    String url = 'https://api.pixivic.com/collections/tags?keyword=$keywords';
    Map<String, String> headers = {'authorization': prefs.getString('auth')};

    try {
      Response response =
          await Dio().get(url, options: Options(headers: headers));
      if (response.data['data'] != null)
        _tagsAdvice = _tagsAdvice + response.data['data'];
      print(_tagsAdvice);
      notifyListeners();
      // _tagsAdvice = [];
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
  }

  addTagToTagsList(Map tagData) {
    if (!_tags.contains(tagData)) _tags.add(tagData);
    notifyListeners();
  }

  removeTagFromTagsList(Map tagData) {
    _tags.removeWhere((element) => element['tagName'] == tagData['tagName']);
    notifyListeners();
  }
}

class CollectionUserDataModel with ChangeNotifier {
  List userCollectionList;

  CollectionUserDataModel() {
    userCollectionList = [];
    if (prefs.getString('auth') != '') {
      getCollectionList();
    }
  }

  bool isUserCollectionListEmpty() {
    print(userCollectionList);
    if (userCollectionList.length == 0)
      return true;
    else
      return false;
  }

  getCollectionList() async {
    List collectionList;
    String url =
        'https://api.pixivic.com/users/${prefs.getInt('id')}/collections';
    Map<String, String> headers = {'authorization': prefs.getString('auth')};
    try {
      Response response =
          await Dio().get(url, options: Options(headers: headers));
      // print(response.data['data']);
      collectionList = response.data['data'];
      // print('The user album list:\n$collectionList');
      userCollectionList = collectionList;
      // print(userCollectionList);
      notifyListeners();
    } on DioError catch (e) {
      if (e.response != null) {
        BotToast.showSimpleNotification(title: e.response.data['message']);
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
        return null;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        BotToast.showSimpleNotification(title: e.message);
        print(e.request);
        print(e.message);
        return null;
      }
    }
  }

  cleanUserCollectionList() {
    userCollectionList = [];
    notifyListeners();
  }
}
