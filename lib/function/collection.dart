/* 
fxt0706 2020-08-20
description: 文件封装了与画集有关的相关功能
*/

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pixivic/biz/collection/service/collection_service.dart';
import 'package:pixivic/common/config/get_it_config.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:tuple/tuple.dart';

import '../data/common.dart';
import '../data/texts.dart';
import 'package:pixivic/provider/collection_model.dart';
import 'package:pixivic/provider/pic_page_model.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/common/do/collection.dart';

showAddToCollection(BuildContext contextFrom, List selectedPicIdList,
    {bool multiSelect = true}) {
  final screen = ScreenUtil();
  final texts = TextZhPicDetailPage();

  showDialog(
      context: contextFrom,
      builder: (context) {
        bool onAddIllust = false;

        return Selector<CollectionUserDataModel, Tuple2>(
            selector: (context, collectionUserDataModel) => Tuple2(
                collectionUserDataModel.userCollectionList,
                collectionUserDataModel.isUserCollectionListEmpty()),
            builder: (context, tuple2, _) => tuple2.item2
                ? AlertDialog(
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
                              // Navigator.of(context).pop();
                              showCollectionInfoEditDialog(context);
                            },
                          ),
                        )
                      ],
                    ),
                  )
                : AlertDialog(
                    scrollable: true,
                    content: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                              padding:
                                  EdgeInsets.only(bottom: screen.setHeight(5)),
                              alignment: Alignment.center,
                              child: Text(
                                texts.addToCollection,
                                style: TextStyle(color: Colors.orangeAccent),
                              )),
                          Container(
                            height: screen.setHeight(tuple2.item1.length <= 7
                                ? screen.setHeight(50) * tuple2.item1.length
                                : screen.setHeight(50) * 7),
                            width: screen.setWidth(250),
                            child: ListView.builder(
                                itemCount: tuple2.item1.length,
                                itemBuilder: (context, int index) {
                                  return Container(
                                    child: ListTile(
                                      title: Text(tuple2.item1[index]['title']),
                                      subtitle:
                                          Text(tuple2.item1[index]['caption']),
                                      onTap: () {
                                        if (!onAddIllust) {
                                          onAddIllust = true;
                                          addIllustToCollection(
                                                  contextFrom,
                                                  selectedPicIdList,
                                                  tuple2.item1[index]['id']
                                                      .toString(),
                                                  multiSelect)
                                              .then((value) {
                                            onAddIllust = false;
                                            print('添加画作结果: $value');
                                            if (value)
                                              Navigator.of(context).pop();
                                          });
                                        }
                                      },
                                    ),
                                  );
                                }),
                          ),
                          Container(
                              width: screen.setWidth(100),
                              padding:
                                  EdgeInsets.only(top: screen.setHeight(8)),
                              child: FlatButton(
                                  child: Icon(Icons.add),
                                  shape: StadiumBorder(),
                                  onPressed: () {
                                    // Navigator.of(context).pop();
                                    showCollectionInfoEditDialog(contextFrom);
                                  })),
                        ]),
                  ));
      });
}

showCollectionInfoEditDialog(
  BuildContext context, {
  bool isCreate = true,
  int index,
}) async {
  TextEditingController title;
  TextEditingController caption;
  TextZhCollection texts = TextZhCollection();
  Collection inputData;
  if (!isCreate && index != null) {
    inputData = Provider.of<CollectionUserDataModel>(context, listen: false)
        .userCollectionList[index];
    title = TextEditingController(text: inputData.title);
    caption = TextEditingController(text: inputData.caption);
    Provider.of<NewCollectionParameterModel>(context, listen: false)
        .passTags(inputData.tagList);
    Provider.of<NewCollectionParameterModel>(context, listen: false)
        .public(inputData.isPublic == 1 ? true : false);
    Provider.of<NewCollectionParameterModel>(context, listen: false)
        .sexy(inputData.pornWarning == 1 ? true : false);
    Provider.of<NewCollectionParameterModel>(context, listen: false)
        .comment(inputData.forbidComment == 1 ? true : false);
  } else {
    title = TextEditingController();
    caption = TextEditingController();
    Provider.of<NewCollectionParameterModel>(context, listen: false)
        .cleanTags();
  }
  //TODO：点击按钮后，键盘自动释放焦点
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        bool onPostCollection = false;
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
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil().setSp(13),
                                color: Colors.grey[700]),
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
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: ScreenUtil().setSp(11),
                                color: Colors.grey[500]),
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
                          child: Text(
                            texts.addTag,
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        isCreate
                            ? Container()
                            : FlatButton(
                                shape: StadiumBorder(),
                                onPressed: () {
                                  deleteCollection(
                                      context,
                                      Provider.of<CollectionUserDataModel>(
                                              context,
                                              listen: false)
                                          .userCollectionList[index]
                                          .id
                                          .toString());
                                },
                                child: Text(
                                  texts.removeCollection,
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w300),
                                ),
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
                          isCreate
                              ? texts.createCollection
                              : texts.editCollection,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        color: Colors.orange[300],
                        shape: StadiumBorder(),
                        onPressed: () {
                          print(
                              'newCollectionParameterModel.tags: ${newCollectionParameterModel.tags}');
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
                            if (!onPostCollection) {
                              onPostCollection = true;
                              if (isCreate)
                                postNewCollection(payload).then((value) {
                                  if (value) {
                                    onPostCollection = false;
                                    Provider.of<CollectionUserDataModel>(
                                            context,
                                            listen: false)
                                        .getCollectionList();
                                    Navigator.of(context).pop();
                                  }
                                });
                              else {
                                payload['id'] = inputData.id;
                                putEditCollection(
                                        payload, inputData.id.toString())
                                    .then((value) {
                                  if (value) {
                                    onPostCollection = false;
                                    Provider.of<CollectionUserDataModel>(
                                            context,
                                            listen: false)
                                        .getCollectionList();
                                    Navigator.of(context).pop();
                                  }
                                });
                              }
                            }
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
                        width: ScreenUtil().setWidth(270),
                        height: ScreenUtil().setWidth(500),
                        padding: EdgeInsets.zero,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: 0,
                              child: Column(
                                children: [
                                  Container(
                                    width: ScreenUtil().setWidth(270),
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
                                          .map((item) =>
                                              singleTag(context, item, false))
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
                                              borderSide: BorderSide(
                                                  color: Colors.grey)),
                                        ),
                                        onEditingComplete: () {
                                          newCollectionParameterModel
                                              .getTagAdvice(tagInput.text);
                                        }),
                                  ),
                                  Container(
                                    width: ScreenUtil().setWidth(250),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      children: newCollectionParameterModel
                                          .tagsAdvice
                                          .map((item) =>
                                              singleTag(context, item, true))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                                bottom: 0,
                                child: Container(
                                  child: FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Icon(Icons.arrow_back)),
                                ))
                          ],
                        ))));
      }).then((value) {
    Provider.of<NewCollectionParameterModel>(context, listen: false)
        .clearTagAdvice();
  });
}

// 将选中画作添加到指定的画集中
addIllustToCollection(BuildContext contextFrom, List illustIdList,
    String collectionId, bool multiSelect) async {
  print('illustIdList: $illustIdList');
  String url = '/collections/$collectionId/illustrations';
  CancelFunc cancelLoading;

  try {
    cancelLoading = BotToast.showLoading();
    // Response response = await dioPixivic.post(url, data: illustIdList);
    Result result = await getIt<CollectionService>()
        .queryAddIllustToCollection(int.parse(collectionId), illustIdList);
    cancelLoading();
    BotToast.showSimpleNotification(title: result.message);
    print(result.data);
    if (multiSelect)
      Provider.of<PicPageModel>(contextFrom, listen: false).cleanSelectedList();
    Provider.of<CollectionUserDataModel>(contextFrom, listen: false)
        .getCollectionList();
    return true;
  } catch (e) {
    cancelLoading();
    return false;
  }
}

setCollectionCover(BuildContext contextFrom, String collectionId,
    List<int> illustIdList) async {
  try {
    print(illustIdList);
    await dioPixivic.put('/collections/$collectionId/cover',
        data: illustIdList);
    //TODO 调试不通 400错误
    // await getIt<CollectionService>().queryModifyCollectionCover(
    //     int.parse(collectionId), illustIdList);
    Provider.of<PicPageModel>(contextFrom, listen: false).cleanSelectedList();
    Provider.of<CollectionUserDataModel>(contextFrom, listen: false)
        .getCollectionList();
  } finally {}
}

removeIllustFromCollection(
    BuildContext contextFrom, String collectionId, List illustIdList) async {
  try {
    // await dioPixivic.delete('/collections/$collectionId/illustrations',
    //     data: illustIdList);
    await getIt<CollectionService>()
        .queryBulkDeleteCollection(int.parse(collectionId), illustIdList);
    Provider.of<PicPageModel>(contextFrom, listen: false).cleanSelectedList();
    Provider.of<PicPageModel>(contextFrom, listen: false).initAndLoadData();
    Provider.of<CollectionUserDataModel>(contextFrom, listen: false)
        .getCollectionList();
  } finally {}
}

postNewCollection(Map<String, dynamic> payload) async {
  String url = '/collections';
  Map<String, String> headers = {'authorization': prefs.getString('auth')};
  CancelFunc cancelLoading;

  if (payload['tagList'] != null) {
    try {
      cancelLoading = BotToast.showLoading();
      Result result = await getIt<CollectionService>()
          .queryCreateCollection(payload, prefs.getString('auth'));
      // Response response = await dioPixivic.post(url,
      //     data: payload, options: Options(headers: headers));
      cancelLoading();
      print(result.data);
      BotToast.showSimpleNotification(title: result.message);
      return true;
    } catch (e) {
      cancelLoading();
      return false;
    }
  } else {
    BotToast.showSimpleNotification(title: TextZhCollection().needForTag);
    return false;
  }
}

deleteCollection(BuildContext contextFrom, String collectionId) {
  final texts = TextZhPicDetailPage();

  showDialog(
      context: contextFrom,
      builder: (context) {
        return AlertDialog(
          title: Text(texts.deleteCollectionTitle),
          content: Text(texts.deleteCollectionContent),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(texts.deleteCollectionNo)),
            FlatButton(
              onPressed: () async {
                try {
                  // await dioPixivic.delete('/collections/$collectionId');
                  getIt<CollectionService>()
                      .queryDeleteCollection(int.parse(collectionId));
                  Provider.of<CollectionUserDataModel>(contextFrom,
                          listen: false)
                      .getCollectionList();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } finally {}
              },
              child: Text(
                texts.deleteCollectionYes,
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        );
      });
}

putEditCollection(Map<String, dynamic> payload, String collectionId) async {
  String url = 'https://pix.ipv4.host/collections/$collectionId';
  // print(payload);
  if (payload['tagList'] != null) {
    try {
      // Response response = await dioPixivic.put(url, data: payload);
      Result result = await getIt<CollectionService>()
          .queryUpdateCollection(int.parse(collectionId), payload);
      BotToast.showSimpleNotification(title: result.message);
      return true;
    } catch (e) {
      return false;
    }
  } else {
    BotToast.showSimpleNotification(title: TextZhCollection().needForTag);
    return false;
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

Widget singleTag(context, TagList data, bool advice) {
  return Container(
    padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(1.5),
        right: ScreenUtil().setWidth(1.5),
        top: ScreenUtil().setWidth(4)),
    child: ButtonTheme(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //set _InputPadding to zero
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
              data.tagName,
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
