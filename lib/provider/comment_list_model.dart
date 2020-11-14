import 'package:flutter/material.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../data/common.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/provider/meme_model.dart';

class CommentListModel with ChangeNotifier, WidgetsBindingObserver {
  int illustId;
  int replyToId;
  int currentPage = 1;
  int replyParentId;
  List commentList;
  List jsonList;
  ScrollController scrollController;
  bool loadMoreAble = true;
  bool isMemeMode = false;
  bool isReplyAble = true;
  String replyToName;
  String hintText;
  TextEditingController textEditingController;
  FocusNode replyFocus;
  TextZhCommentCell texts = TextZhCommentCell();

  BuildContext context;
  double curKeyboardH = 0;
  double storeKeyboardH = 250;
  double faceH = 0;

  CommentListModel(this.illustId, this.replyToId, this.replyToName,
      this.replyParentId, this.context) {
    scrollController = ScrollController()..addListener(_autoLoading);
    textEditingController = TextEditingController();
    replyFocus = FocusNode()..addListener(replyFocusListener);

    this.hintText = texts.addCommentHint;

    WidgetsBinding.instance.addObserver(this);

    //初始化Model时拉取评论数据
    loadComments(this.illustId).then((value) {
      commentList = value;
      notifyListeners();
    });
  }

  @override
  void didChangeMetrics() {
    final renderObject = context.findRenderObject();
    final renderBox = renderObject as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final widgetRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
    final keyboardTopPixels =
        window.physicalSize.height - window.viewInsets.bottom;
    final keyboardTopPoints = keyboardTopPixels / window.devicePixelRatio;
    double keyH = widgetRect.bottom - keyboardTopPoints;
    curKeyboardH = keyH >= 0 ? keyH : -keyH;
    notifyListeners();
    storeKeyboardH = keyH;
    if (prefs.getDouble('KeyboardH') == null) {
      prefs.setDouble('KeyboardH', storeKeyboardH);
    }
    super.didChangeMetrics();
  }

  // 根据回复框的焦点做判断
  replyFocusListener() {
    if (replyFocus.hasFocus) {
      curKeyboardH = prefs.getDouble('KeyboardH');
      notifyListeners();
      print('replyFocus on focus');
      if (isMemeMode) flipMemeMode();
      if (replyToName != '') {
        print('replyFocusListener: replyParentId is $replyParentId');
        hintText = '@$replyToName:';
        notifyListeners();
      }
    } else if (!replyFocus.hasFocus) {
      print('replyFocus released');

      if (!isMemeMode) {
        replyToId = 0;
        replyToName = '';
        replyParentId = 0;
        hintText = texts.addCommentHint;
        // print(textEditingController.text);
        notifyListeners();
      }
    }
  }

  reply() async {
    if (isReplyAble) {
      if (prefs.getString('auth') == '') {
        BotToast.showSimpleNotification(title: texts.pleaseLogin);
        return false;
      }

      if (textEditingController.text == '') {
        BotToast.showSimpleNotification(title: texts.commentCannotBeBlank);
        return false;
      }

      isReplyAble = false;

      String url = '/illusts/$illustId/comments';
      CancelFunc cancelLoading;
      Map<String, dynamic> payload = {
        'content': textEditingController.text,
        'parentId': replyParentId.toString(),
        'replyFromName': prefs.getString('name'),
        'replyTo': replyToId.toString(),
        'replyToName': replyToName,
        'platform': 'Mobile 客户端'
      };

      await dioPixivic.post(
        url,
        data: payload,
        onReceiveProgress: (count, total) {
          cancelLoading = BotToast.showLoading();
        },
      );
      cancelLoading();

      textEditingController.text = '';
      replyToId = 0;
      replyToName = '';
      replyParentId = 0;
      hintText = texts.addCommentHint;

      loadComments(illustId).then((value) {
        commentList = value;
        notifyListeners();
      });
      isReplyAble = true;
      return true;
    } else {
      return false;
    }
  }

  replyMeme(String memeGroup, String memeId) async {
    if (isReplyAble) {
      if (prefs.getString('auth') == '') {
        BotToast.showSimpleNotification(title: texts.pleaseLogin);
        return false;
      }

      isReplyAble = false;

      String content = '[${memeGroup}_$memeId]';
      String url = '/illusts/$illustId/comments';
      CancelFunc cancelLoading;
      Map<String, dynamic> payload = {
        'content': content,
        'parentId': replyParentId.toString(),
        'replyFromName': prefs.getString('name'),
        'replyTo': replyToId.toString(),
        'replyToName': replyToName,
        'platform': 'Mobile 客户端'
      };
      await dioPixivic.post(
        url,
        data: payload,
        onReceiveProgress: (count, total) {
          cancelLoading = BotToast.showLoading();
        },
      );
      cancelLoading();

      replyToId = 0;
      replyToName = '';
      replyParentId = 0;
      hintText = texts.addCommentHint;

      loadComments(illustId).then((value) {
        commentList = value;
        notifyListeners();
      });
      flipMemeMode();
      isReplyAble = true;
      return true;
    } else {
      return false;
    }
  }

  likeComment(int parentIndex, {int subIndex}) async {
    String url = '/user/likedComments';
    Map<String, dynamic> payload = {
      'commentAppId': commentList[0]['id'],
      'commentAppType': commentList[0]['appType'],
      'commentId': subIndex == null
          ? commentList[parentIndex]['id']
          : commentList[parentIndex]['subCommentList'][subIndex]['id'],
    };
    var result = await dioPixivic.post(
      url,
      data: payload,
    );
    if (result.runtimeType != bool) {
      if (subIndex == null) {
        commentList[parentIndex]['isLike'] = true;
        commentList[parentIndex]['likedCount'] += 1;
      } else {
        commentList[parentIndex]['subCommentList'][subIndex]['isLike'] = true;
        commentList[parentIndex]['subCommentList'][subIndex]['likedCount'] += 1;
      }

      notifyListeners();
      return true;
    } else
      return false;
  }

  unlikeComment(int parentIndex, {int subIndex}) async {
    String commentId = subIndex == null
        ? commentList[parentIndex]['id']
        : commentList[parentIndex]['subCommentList'][subIndex]['id'];
    String url = 'ikedComments/${commentList[0]['appType']}/${commentList[0]['appId']}/$commentId';
    var result = await dioPixivic.delete(
      url,
    );
    if (result.runtimeType != bool) {
      if (subIndex == null) {
        commentList[parentIndex]['isLike'] = false;
        commentList[parentIndex]['likedCount'] -= 1;
      } else {
        commentList[parentIndex]['subCommentList'][subIndex]['isLike'] = false;
        commentList[parentIndex]['subCommentList'][subIndex]['likedCount'] -= 1;
      }
      notifyListeners();
      return true;
    } else
      return false;
  }

  //自动加载数据
  _autoLoading() {
    if ((scrollController.position.extentAfter < 500) && loadMoreAble) {
      print("Load Comment");
      loadMoreAble = false;
      currentPage++;
      print('current page is $currentPage');
      try {
        loadComments(illustId, page: currentPage).then((value) {
          if (value.length != 0) {
            commentList = commentList + value;
            notifyListeners();
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

//请求数据
  loadComments(int illustId, {int page = 1}) async {
    String url =
        'https://pix.ipv4.host/illusts/$illustId/comments?page=$page&pageSize=10';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.statusCode == 200 && response.data['data'] != null) {
      // print(response.data);
      jsonList = response.data['data'];
      return jsonList;
    } else if (response.statusCode == 200 && response.data['data'] == null) {
      print('comments: null but 200');
      return jsonList = [];
    } else {
      BotToast.showSimpleNotification(title: response.data['message']);
    }
  }

  flipMemeMode() {
    isMemeMode = !isMemeMode;
    notifyListeners();
  }

  @override
  void dispose() {
    commentList = null;
    textEditingController.dispose();
    replyFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
