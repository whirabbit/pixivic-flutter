import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';

import '../data/common.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/biz/comment/service/comment_service.dart';
import 'package:pixivic/common/config/get_it_config.dart';
import 'package:pixivic/common/do/comment.dart';

class CommentListModel with ChangeNotifier, WidgetsBindingObserver {
  int illustId;
  int replyToId;
  int currentPage = 1;
  int replyParentId;
  List<Comment> commentList;
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
  double currentKeyboardHeight = 0;
  double memeBoxHeight = prefs.getDouble('keyboardHeight') != 0
      ? prefs.getDouble('keyboardHeight')
      : 250;

  CommentListModel(this.illustId, this.replyToId, this.replyToName,
      this.replyParentId, this.context) {
    scrollController = ScrollController()..addListener(_autoLoading);
    textEditingController = TextEditingController();
    replyFocus = FocusNode()..addListener(replyFocusListener);

    hintText = texts.addCommentHint;

    WidgetsBinding.instance.addObserver(this);

    //初始化Model时拉取评论数据
    loadComments(this.illustId).then((value) {
      commentList = value;
      notifyListeners();
    });
    // print('CommentListModel: $memeBoxHeight');
  }

  // 对键盘高度的监听，同时赋值键盘高度为 memeBox 高度
  @override
  void didChangeMetrics() {
    print('CommentListModel run didChangeMetrics');
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
    double keyHeight = widgetRect.bottom - keyboardTopPoints;

    if (keyHeight > 0) {
      currentKeyboardHeight = keyHeight;
      memeBoxHeight = keyHeight;
      prefs.setDouble('keyboardHeight', memeBoxHeight);
      print('didChangeMetrics memeBoxHeight: $keyHeight');
    } else {
      currentKeyboardHeight = 0;
    }

    notifyListeners();
    super.didChangeMetrics();
  }

  // 根据回复框的焦点做判断
  replyFocusListener() {
    if (replyFocus.hasFocus) {
      // currentKeyboardHeight = prefs.getDouble('KeyboardHeight');
      // notifyListeners();
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

      try {
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
      } catch (e) {
        isReplyAble = true;
        cancelLoading();
        return false;
      }
    } else {
      isReplyAble = true;
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
      try {
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
      } catch (e) {
        isReplyAble = true;
        cancelLoading();
        return false;
      }
    } else {
      isReplyAble = true;
      return false;
    }
  }

  likeComment(int parentIndex, {int subIndex}) async {
    print('========likeComment===========');
    String url = '/user/likedComments';
    Map<String, dynamic> payload = {
      'commentAppId': commentList[0].appId,
      'commentAppType': commentList[0].appType,
      'commentId': subIndex == null
          ? commentList[parentIndex].id
          : commentList[parentIndex].subCommentList[subIndex].id,
    };
    print(payload);

    try {
      dioPixivic.post(
        url,
        data: payload,
      );
      print(commentList[parentIndex].isLike);
      if (subIndex == null) {
        commentList[parentIndex].isLike = true;
        commentList[parentIndex].likedCount += 1;
      } else {
        commentList[parentIndex].subCommentList[subIndex].isLike = true;
        commentList[parentIndex].subCommentList[subIndex].likedCount += 1;
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  unlikeComment(int parentIndex, {int subIndex}) async {
    print('========unlikeComment===========');
    int commentId = subIndex == null
        ? commentList[parentIndex].id
        : commentList[parentIndex].subCommentList[subIndex].id;
    String url =
        '/user/likedComments/${commentList[0].appType}/${commentList[0].appId}/$commentId';
    // print(url);
    try {
      await dioPixivic.delete(
        url,
      );
      if (subIndex == null) {
        commentList[parentIndex].isLike = false;
        commentList[parentIndex].likedCount -= 1;
      } else {
        commentList[parentIndex].subCommentList[subIndex].isLike = false;
        commentList[parentIndex].subCommentList[subIndex].likedCount -= 1;
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
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
          if (value != null) {
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
  loadComments(int illustId, {int page = 1}) {
    return getIt<CommentService>()
        .queryGetComment(AppType.illusts, illustId, page, 10)
        .then((value) => value);
    // String url = '/illusts/$illustId/comments?page=$page&pageSize=10';
    // Response response = await dioPixivic.get(url);
    // if (response.statusCode == 200 && response.data['data'] != null) {
    //   // print(response.data);
    //   jsonList = response.data['data'];
    //   return jsonList;
    // } else if (response.statusCode == 200 && response.data['data'] == null) {
    //   print('comments: no comments but code 200');
    //   return [];
    // } else {
    //   BotToast.showSimpleNotification(title: response.data['message']);
    // }
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
