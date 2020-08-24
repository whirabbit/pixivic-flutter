/* 
fxt0706 2020-08-20
description: 文件封装了与画集有关的相关功能
*/
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../data/common.dart';
import '../data/texts.dart';

// 获取当前登录用户的画集列表
getAlbumList() async {
  List albumList;
  String url =
      'https://api.pixivic.com/users/${prefs.getInt('id')}/collections';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  try {
    Response response =
        await Dio().get(url, options: Options(headers: headers));
    // print(response.data['data']);
    albumList = response.data['data'];
    // print('The user album list:\n$albumList');
    return albumList;
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

// 将选中画作添加到指定的画集中
addIllustToAlbumn(int illustId, int albumnId) async {
  String url = 'https://api.pixivic.com/collections/$albumnId/illustrations';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  Map<String, String> data = {'illust_id': illustId.toString()};
  try {
    Response response = await Dio().post(url,
        options: Options(
          headers: headers,
        ),
        data: data);
    BotToast.showSimpleNotification(title: response.data['message']);
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

showAddNewAlbumnDialog(BuildContext context) {
  TextEditingController title = TextEditingController();
  TextEditingController caption = TextEditingController();
  TextZhAlbumn texts = TextZhAlbumn();

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<NewAlbumnParameterModel>(
          builder: (context, NewAlbumnParameterModel newAlbumnParameterModel,
                  child) =>
              AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              alignment: Alignment.topCenter,
              width: ScreenUtil().setWidth(260),
              height: ScreenUtil().setHeight(280),
              child: Stack(
                children: [
                  Positioned(
                    width: ScreenUtil().setWidth(260),
                    top: ScreenUtil().setHeight(10),
                    child: Column(
                      children: [
                        Container(
                            width: ScreenUtil().setWidth(260),
                            height: ScreenUtil().setHeight(30),
                            alignment: Alignment.center,
                            color: Colors.orange[300],
                            padding: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(8)),
                            child: Text(
                              texts.newAlbumnTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            )),
                        Container(
                          width: ScreenUtil().setWidth(260),
                          height: ScreenUtil().setHeight(30),
                          child: TextField(
                            cursorColor: Colors.orange,
                            controller: title,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: texts.inputAlbumnTitle,
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[300]),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(260),
                          child: TextField(
                            cursorColor: Colors.orange,
                            controller: caption,
                            maxLines: 3,
                            minLines: 1,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              hintText: texts.inputAlbumnCaption,
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[300]),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newAlbumnParameterModel.isPublic,
                            dense: true,
                            onChanged: (value) {
                              newAlbumnParameterModel.public(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title: Text(
                              texts.isPulic,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newAlbumnParameterModel.isSexy,
                            dense: true,
                            onChanged: (value) {
                              newAlbumnParameterModel.sexy(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title:
                                Text(texts.isSexy, style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newAlbumnParameterModel.allowComment,
                            dense: true,
                            onChanged: (value) {
                              newAlbumnParameterModel.comment(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title: Text(texts.allowComment, style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        FlatButton(
                          shape: StadiumBorder(),
                          onPressed: () {
                            showTagSelector(context);
                          },
                          child: Text(texts.addTag),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    width: ScreenUtil().setWidth(260),
                    bottom: ScreenUtil().setHeight(8),
                    child: Container(
                      width: ScreenUtil().setWidth(260),
                      height: ScreenUtil().setHeight(30),
                      color: Colors.orange[200],
                      alignment: Alignment.center,
                      child: FlatButton(
                        child: Text(
                          texts.submit,
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.orange[200],
                        shape: StadiumBorder(),
                        onPressed: () {
                          Map<String, dynamic> payload = {
                            'title': title.text,
                            'caption': caption.text,
                            'isPublic':
                                newAlbumnParameterModel.isPublic ? 1 : 0,
                            'pornWarning':
                                newAlbumnParameterModel.isSexy ? 1 : 0,
                            'forbidComment':
                                newAlbumnParameterModel.allowComment ? 1 : 0,
                          };
                          postNewAlbumn(payload);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
}

showTagSelector(context) async {
  await showDialog(
      context: context,
      builder: (context) {
        TextEditingController tagInput = TextEditingController();
        return Consumer<NewAlbumnParameterModel>(
            builder: (context, NewAlbumnParameterModel newAlbumnParameterModel,
                    child) =>
                AlertDialog(
                  content: Container(
                      width: ScreenUtil().setWidth(324),
                      height: ScreenUtil().setWidth(400),
                      child: Column(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(280),
                            child: TextField(
                                controller: tagInput,
                                decoration: InputDecoration(
                                  hintText: '输入你想要添加的标签',
                                  isDense: true,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                ),
                                onEditingComplete: () {
                                  newAlbumnParameterModel
                                      .getTagAdvice(tagInput.text);
                                }),
                          ),
                          Wrap(
                            children: newAlbumnParameterModel.tagsAdvice
                                .map((item) => singleTag(item['tagName'], true))
                                .toList(),
                          )
                        ],
                      )),
                ));
      }).then((value) {
    NewAlbumnParameterModel().clearTagAdvice();
  });
}

postNewAlbumn(Map<String, dynamic> payload) async {
  // TODO: fill postNewAlbumn
  // String url = 'https://api.pixivic.com/collections';
  // Map<String, String> headers = {'authorization': prefs.getString('auth')};
}

Widget singleTag(String label, bool advice) {
  return Container(
    padding: EdgeInsets.all(ScreenUtil().setWidth(3)),
    child: ButtonTheme(
      height: ScreenUtil().setHeight(20),
      minWidth: ScreenUtil().setWidth(2),
      buttonColor: Colors.grey[100],
      splashColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
      child: OutlineButton(
        onPressed: () {},
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey),
            ),
            !advice ? Icon(
              Icons.cancel,
              color: Colors.grey,
              size: ScreenUtil().setWidth(13),
            ) : Container()  
          ],
        ),
      ),
    ),
  );
}

class NewAlbumnParameterModel with ChangeNotifier {
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

  void public(bool result) {
    _isPublic = result;
    notifyListeners();
  }

  void sexy(bool result) {
    _isSexy = result;
    notifyListeners();
  }

  void comment(bool result) {
    _allowComment = result;
    notifyListeners();
  }

  void cleanTag() {
    _tags = [];
    notifyListeners();
  }

  void addTag(String tag) {
    _tags.add(tag);
  }

  void clearTagAdvice() {
    _tagsAdvice = [];
  }

  void getTagAdvice(String keywords) async {
    _tagsAdvice = [
      {'tagName': keywords}
    ];
    notifyListeners();
    String url = 'https://api.pixivic.com/collections/tags?keyword=$keywords';
    Map<String, String> headers = {'authorization': prefs.getString('auth')};

    try {
      Response response =
          await Dio().get(url, options: Options(headers: headers));
      _tagsAdvice = response.data['data'];
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
}
