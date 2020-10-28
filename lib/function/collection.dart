/* 
fxt0706 2020-08-20
description: 文件封装了与画集有关的相关功能
*/
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../data/common.dart';
import '../data/texts.dart';
import 'package:pixivic/provider/collection_model.dart';
import 'package:pixivic/provider/pic_page_model.dart';

showAddToCollection(BuildContext contextFrom, List selectedPicIdList) {
  final screen = ScreenUtil();
  final texts = TextZhPicDetailPage();

  if (!Provider.of<CollectionUserDataModel>(contextFrom, listen: false)
      .isUserCollectionListEmpty())
    showDialog(
        context: contextFrom,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            content: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                      padding: EdgeInsets.only(bottom: screen.setHeight(5)),
                      alignment: Alignment.center,
                      child: Text(
                        texts.addToCollection,
                        style: TextStyle(color: Colors.orangeAccent),
                      )),
                  Selector<CollectionUserDataModel, List>(
                    selector: (context, collectionUserDataModel) =>
                        collectionUserDataModel.userCollectionList,
                    builder: (context, userCollectionList, _) => Container(
                      height: screen.setHeight(userCollectionList.length <= 7
                          ? screen.setHeight(40) * userCollectionList.length
                          : screen.setHeight(40) * 7),
                      width: screen.setWidth(250),
                      child: ListView.builder(
                          itemCount: userCollectionList.length,
                          itemBuilder: (context, int index) {
                            return Container(
                              child: ListTile(
                                title: Text(userCollectionList[index]['title']),
                                subtitle:
                                    Text(userCollectionList[index]['caption']),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  addIllustToCollection(
                                      contextFrom,
                                      selectedPicIdList,
                                      userCollectionList[index]['id']);
                                },
                              ),
                            );
                          }),
                    ),
                  ),
                  Container(
                      width: screen.setWidth(100),
                      padding: EdgeInsets.only(top: screen.setHeight(8)),
                      child: FlatButton(
                          child: Icon(Icons.add),
                          shape: StadiumBorder(),
                          onPressed: () {
                            Navigator.of(context).pop();
                            showAddNewCollectionDialog(context);
                          })),
                ]),
          );
        });
  else {
    showDialog(
        context: contextFrom,
        builder: (context) {
          return AlertDialog(
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Lottie.asset('image/empty-box.json',
                    repeat: false, height: ScreenUtil().setHeight(80)),
                Container(
                  // width: screen.setWidth(300),
                  padding: EdgeInsets.only(top: screen.setHeight(8)),
                  child: Text(texts.addFirstCollection),
                ),
                Container(
                  width: screen.setWidth(100),
                  padding: EdgeInsets.only(top: screen.setHeight(8)),
                  child: FlatButton(
                    child: Icon(Icons.add),
                    shape: StadiumBorder(),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showAddNewCollectionDialog(context);
                    },
                  ),
                )
              ],
            ),
          );
        });
  }
}

showAddNewCollectionDialog(BuildContext context) async {
  TextEditingController title = TextEditingController();
  TextEditingController caption = TextEditingController();
  TextZhCollection texts = TextZhCollection();
  Provider.of<NewCollectionParameterModel>(context, listen: false).cleanTags();
  //TODO：点击按钮后，键盘自动释放焦点
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<NewCollectionParameterModel>(builder: (context,
            NewCollectionParameterModel newCollectionParameterModel, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.all(0),
            content: Container(
              alignment: Alignment.topCenter,
              width: ScreenUtil().setWidth(250),
              height: ScreenUtil().setHeight(320),
              child: Stack(
                children: [
                  Positioned(
                    top: ScreenUtil().setHeight(0),
                    child: Column(
                      children: [
                        Container(
                            width: ScreenUtil().setWidth(250),
                            height: ScreenUtil().setHeight(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0)),
                              color: Colors.orange[300],
                            ),
                            alignment: Alignment.center,
                            // padding: EdgeInsets.only(
                            //     bottom: ScreenUtil().setHeight(8)),
                            child: Text(
                              texts.newCollectionTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            )),
                        Container(
                          width: ScreenUtil().setWidth(250),
                          height: ScreenUtil().setHeight(30),
                          child: TextField(
                            cursorColor: Colors.orange,
                            controller: title,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.orangeAccent)),
                              isDense: true,
                              focusColor: Colors.orange,
                              hintText: texts.inputCollectionTitle,
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(250),
                          child: TextField(
                            cursorColor: Colors.orange,
                            controller: caption,
                            maxLines: 3,
                            minLines: 1,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.orangeAccent)),
                              isDense: true,
                              hintText: texts.inputCollectionCaption,
                              hintStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newCollectionParameterModel.isPublic,
                            dense: true,
                            onChanged: (value) {
                              newCollectionParameterModel.public(value);
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
                            value: newCollectionParameterModel.isSexy,
                            dense: true,
                            onChanged: (value) {
                              newCollectionParameterModel.sexy(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title: Text(texts.isSexy,
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(30),
                          child: SwitchListTile(
                            value: newCollectionParameterModel.allowComment,
                            dense: true,
                            onChanged: (value) {
                              newCollectionParameterModel.comment(value);
                            },
                            activeColor: Colors.orangeAccent,
                            title: Text(texts.allowComment,
                                style: TextStyle(fontSize: 14)),
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
                    bottom: ScreenUtil().setHeight(0),
                    child: Container(
                      width: ScreenUtil().setWidth(250),
                      height: ScreenUtil().setHeight(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: FlatButton(
                        child: Text(
                          texts.submit,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        color: Colors.orange[300],
                        shape: StadiumBorder(),
                        onPressed: () {
                          print(newCollectionParameterModel.tags);
                          if (checkBeforePost(title.text, caption.text,
                              newCollectionParameterModel.tags, texts)) {
                            Map<String, dynamic> payload = {
                              'username': prefs.getString('name'),
                              'title': title.text,
                              'caption': caption.text,
                              'isPublic':
                                  newCollectionParameterModel.isPublic ? 1 : 0,
                              'pornWarning':
                                  newCollectionParameterModel.isSexy ? 1 : 0,
                              'forbidComment':
                                  newCollectionParameterModel.allowComment
                                      ? 1
                                      : 0,
                              'tagList': newCollectionParameterModel.tags
                            };
                            postNewCollection(payload).then((value) {
                              if (value) {
                                Provider.of<CollectionUserDataModel>(context,
                                        listen: false)
                                    .getCollectionList();
                                Navigator.of(context).pop();
                              }
                            });
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      });
}

showTagSelector(BuildContext context) async {
  TextZhCollection texts = TextZhCollection();
  await showDialog(
      context: context,
      builder: (context) {
        TextEditingController tagInput = TextEditingController();
        return Consumer<NewCollectionParameterModel>(
            builder: (context,
                    NewCollectionParameterModel newCollectionParameterModel,
                    child) =>
                AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  contentPadding: EdgeInsets.all(0),
                  content: Container(
                      width: ScreenUtil().setWidth(250),
                      height: ScreenUtil().setWidth(400),
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(250),
                            height: ScreenUtil().setHeight(30),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0)),
                              color: Colors.orange[300],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              texts.addTag,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(250),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: newCollectionParameterModel.tags
                                  .map(
                                      (item) => singleTag(context, item, false))
                                  .toList(),
                            ),
                          ),
                          Container(
                            width: ScreenUtil().setWidth(200),
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
                                  newCollectionParameterModel
                                      .getTagAdvice(tagInput.text);
                                }),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: newCollectionParameterModel.tagsAdvice
                                .map((item) => singleTag(context, item, true))
                                .toList(),
                          )
                        ],
                      )),
                ));
      }).then((value) {
    Provider.of<NewCollectionParameterModel>(context, listen: false)
        .clearTagAdvice();
  });
}

// 将选中画作添加到指定的画集中
addIllustToCollection(
    BuildContext contextFrom, List illustIdList, int collectionId) async {
  String url =
      'https://api.pixivic.com/collections/$collectionId/illustrations';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  // Map<String, String> data = {'illust_id': illustIdList.toString()};
  final List data = illustIdList;
  print(data);
  try {
    Response response = await Dio().post(url,
        options: Options(
          headers: headers,
        ),
        data: data);
    print(response.data);
    BotToast.showSimpleNotification(title: response.data['message']);
    // BotToast.showSimpleNotification(title: response.data['data'].toString());
    Provider.of<PicPageModel>(contextFrom, listen: false).cleanSelectedList();
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

postNewCollection(Map<String, dynamic> payload) async {
  String url = 'https://api.pixivic.com/collections';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};

  try {
    if (payload['tagList'] != null) {
      Response response = await Dio()
          .post(url, data: payload, options: Options(headers: headers));
      BotToast.showSimpleNotification(title: response.data['message']);
      return true;
    } else {
      BotToast.showSimpleNotification(title: TextZhCollection().needForTag);
      return false;
    }
  } on DioError catch (e) {
    if (e.response != null) {
      BotToast.showSimpleNotification(title: e.response.data['message']);
      print(e.response.data);
      print(e.response.headers);
      print(e.response.request);
      return false;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      BotToast.showSimpleNotification(title: e.message);
      print(e.request);
      print(e.message);
      return false;
    }
  }
}

checkBeforePost(
    String title, String caption, List tagList, TextZhCollection texts) {
  print(title.length);
  if (title.length < 1) {
    BotToast.showSimpleNotification(title: texts.needForTitle);
    return false;
  } else if (caption.length < 1) {
    BotToast.showSimpleNotification(title: texts.needForCaption);
    return false;
  } else if (tagList.length < 1) {
    BotToast.showSimpleNotification(title: texts.needForTag);
    return false;
  } else {
    return true;
  }
}

Widget singleTag(context, Map data, bool advice) {
  return Container(
    padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(1.5),
        right: ScreenUtil().setWidth(1.5),
        top: ScreenUtil().setWidth(4)),
    child: ButtonTheme(
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap, //set _InputPadding to zero
      height: ScreenUtil().setHeight(20),
      minWidth: ScreenUtil().setWidth(1),
      buttonColor: Colors.grey[100],
      splashColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
      child: OutlineButton(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(5),
            right: ScreenUtil().setWidth(5),
            top: ScreenUtil().setWidth(3),
            bottom: ScreenUtil().setWidth(3)),
        onPressed: () {
          if (advice) {
            Provider.of<NewCollectionParameterModel>(context, listen: false)
                .addTagToTagsList(data);
          } else {
            Provider.of<NewCollectionParameterModel>(context, listen: false)
                .removeTagFromTagsList(data);
          }
        },
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              data['tagName'],
              style: TextStyle(color: Colors.grey),
            ),
            !advice
                ? Icon(
                    Icons.cancel,
                    color: Colors.grey,
                    size: ScreenUtil().setWidth(13),
                  )
                : SizedBox(width: 0)
          ],
        ),
      ),
    ),
  );
}
