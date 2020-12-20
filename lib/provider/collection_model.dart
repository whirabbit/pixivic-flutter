import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/data/common.dart';
import 'package:pixivic/function/dio_client.dart';

enum CollectionMode { self, user }

class CollectionUiModel with ChangeNotifier {
  /* 画集 model 处理两块内容，展示画集卡片的列表(Viewer)，以及打开画集后的列表(Collection)  */

  String viewerMode;
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

  CollectionUiModel() {
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
        '/users/${prefs.getInt('id')}/collections?page=$currentViewerPage&pagesize=10';

    try {
      Response response = await dioPixivic.get(url);
      if (response.data['data'] != null) {
        viewerList = viewerList + response.data['data'];
      } else if (response.data['data'] == null) {
        onViewerBottom = true;
      }
    } catch (e) {}
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

  passTags(List tags) {
    _tags = tags;
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
    String url = '/collections/tags?keyword=$keywords';

    try {
      Response response = await dioPixivic.get(url);
      if (response.data['data'] != null)
        _tagsAdvice = _tagsAdvice + response.data['data'];
      print(_tagsAdvice);
      notifyListeners();
    } catch (e) {}
    // _tagsAdvice = [];
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
  bool lock;

  CollectionUserDataModel() {
    userCollectionList = [];
    lock = false;
    if (prefs.getString('auth') != '') {
      print('get collection list from user');
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
    if (!lock) {
      lock = true;
      userCollectionList = [];
      List collectionList;
      int page = 1;
      String url =
          '/users/${prefs.getInt('id')}/collections?page=$page&pagesize=10';
      bool isEnd = false;
      while (!isEnd) {
        // print(response.data['data']);
        try {
          Response response = await dioPixivic.get(url);
          collectionList = response.data['data'] ?? [];
          // print('The user album list:\n$collectionList');
          userCollectionList += collectionList;
          print('collectionList.length: ${collectionList.length}');
          isEnd = collectionList.length == 0 ? true : false;
          page += 1;
          url =
              '/users/${prefs.getInt('id')}/collections?page=$page&pagesize=10';
          if (isEnd) notifyListeners();
          lock = false;
          // print(userCollectionList);
        } catch (e) {
          isEnd = true;
          lock = false;
          return null;
        }
      }
    }
  }

  cleanUserCollectionList() {
    userCollectionList = [];
    notifyListeners();
  }
}
