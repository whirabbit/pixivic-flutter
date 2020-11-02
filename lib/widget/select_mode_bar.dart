import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:vibration/vibration.dart';

import 'package:pixivic/provider/pic_page_model.dart';
import 'package:pixivic/function/collection.dart';
import 'package:pixivic/data/common.dart';

enum SelectMode { normal, collection }

class SelectModeBar extends StatelessWidget {
  final SelectMode selectMode;
  final String collectionId;

  SelectModeBar({this.selectMode = SelectMode.normal, this.collectionId}) {
    print('SelectModeBar construct with ${this.selectMode}');
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PicPageModel, Tuple2<bool, List>>(
      selector: (context, picPageModel) {
        // make list a Runtime constant list or selector won't rebuild when list change
        final list = List.unmodifiable(picPageModel.onSelectedList);
        Tuple2<bool, List> tuple = Tuple2(picPageModel.isInSelectMode(), list);

        return tuple;
      },
      shouldRebuild: (preTuple, nextTuple) {
        if (!preTuple.item1 & nextTuple.item1) {
          Vibration.hasCustomVibrationsSupport().then((value) {
            Vibration.vibrate(duration: 50);
          });
        }
        if (preTuple.item1 != nextTuple.item1 ||
            preTuple.item2.length != nextTuple.item2.length)
          return true;
        else
          return false;
      },
      builder: (context, tuple, _) {
        return AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          top: tuple.item1 ? 0 : ScreenUtil().setHeight(-50),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 350),
            height: ScreenUtil().setHeight(35),
            width: ScreenUtil().setWidth(324),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 13,
                    offset: Offset(5, 5),
                    color: Color(0x73E5E5E5)),
              ],
            ),
            child: SafeArea(
                top: true,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Provider.of<PicPageModel>(context, listen: false)
                                  .cleanSelectedList();
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.times,
                                    color: Colors.orange,
                                    size: ScreenUtil().setWidth(14),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(10),
                                  ),
                                  Text(
                                    tuple.item2.length.toString(),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.orange),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: ScreenUtil().setWidth(20),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.ellipsisV,
                            color: Colors.orange,
                            size: ScreenUtil().setWidth(14),
                          ),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'exit':
                              Provider.of<PicPageModel>(context, listen: false)
                                  .cleanSelectedList();
                              break;
                            case 'addToCollection':
                              if (prefs.getString('auth') == '')
                                BotToast.showSimpleNotification(
                                    title: '请登录后再进行画集操作');
                              else
                                showAddToCollection(
                                    context,
                                    Provider.of<PicPageModel>(context,
                                            listen: false)
                                        .outputPicIdList());
                              break;
                            case 'removeFromCollection':
                              removeIllustFromCollection(
                                  context,
                                  collectionId,
                                  Provider.of<PicPageModel>(context,
                                          listen: false)
                                      .outputPicIdList());
                              break;
                            case 'setCover':
                              setCollectionCover(
                                  context,
                                  collectionId,
                                  Provider.of<PicPageModel>(context,
                                          listen: false)
                                      .outputPicIdList());
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          return popupMenu();
                        },
                      )
                    ])),
          ),
        );
      },
    );
  }

  List popupMenu() {
    print('selectMode: $selectMode');
    if (selectMode == SelectMode.normal)
      return <PopupMenuItem>[
        PopupMenuItem(
          child: popupCell('添加至画集', FontAwesomeIcons.solidBookmark),
          value: 'addToCollection',
        ),
        PopupMenuItem(
          child: popupCell('退出多选', FontAwesomeIcons.doorOpen),
          value: 'exit',
        ),
      ];
    else if (selectMode == SelectMode.collection)
      return <PopupMenuItem>[
        PopupMenuItem(
          child: popupCell('移除图片', FontAwesomeIcons.solidTrashAlt),
          value: 'removeFromCollection',
        ),
        PopupMenuItem(
          child: popupCell('设为封面', FontAwesomeIcons.book),
          value: 'setCover',
        ),
        PopupMenuItem(
          child: popupCell('退出多选', FontAwesomeIcons.doorOpen),
          value: 'exit',
        ),
      ];
    else
      return [];
  }

  Widget popupCell(String text, IconData fontAwesomeIcons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FaIcon(
          fontAwesomeIcons,
          color: Colors.orange,
          size: ScreenUtil().setWidth(12),
        ),
        Text(text)
      ],
    );
  }
}
