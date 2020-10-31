import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import 'package:pixivic/data/texts.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/provider/collection_model.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/widget/image_display.dart';
import 'package:pixivic/page/collection_detail_page.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  CollectionUiModel _model;
  ScrollController _viewerScrollController;
  TextZhCommentCell texts;

  @override
  void initState() {
    texts = TextZhCommentCell();
    _model = CollectionUiModel();
    // _model.getViewerJsonList();
    _viewerScrollController = ScrollController()..addListener(_viewerListener);
    super.initState();
  }

  @override
  void dispose() {
    // Provider.of<CollectionModel>(context, listen: false).resetViewer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PappBar(title: '画集'),
        body: ChangeNotifierProvider.value(
          value: _model,
          child: Builder(builder: (BuildContext insdeConetxt) {
            return collectionBody(insdeConetxt, CollectionMode.self);
          }),
        ));
  }

  Widget collectionBody(context, CollectionMode mode) {
    if (mode == CollectionMode.self) {
      List selfCollectionList =
          Provider.of<CollectionUserDataModel>(context).userCollectionList;
      if (selfCollectionList.length == 0) {
        return nothingHereBox();
      } else {
        return ListView.builder(
          itemCount: selfCollectionList.length,
          itemBuilder: (context, index) {
            return collectionCardCell(index);
          },
        );
      }
    } else if (mode == CollectionMode.user) {
      return loadingBox();
    } else {
      return loadingBox();
    }
  }

  Widget collectionCardCell(int index) {
    // TODO: 若无画作则空的图片

    return Center(
        child: Selector<CollectionUserDataModel, Map>(
            selector: (context, collectionUserDataModel) =>
                collectionUserDataModel.userCollectionList[index],
            builder: (context, data, _) {
              return Container(
                width: ScreenUtil().setWidth(292),
                height: ScreenUtil().setWidth(220),
                margin: EdgeInsets.only(
                    bottom: ScreenUtil().setWidth(14),
                    top: ScreenUtil().setWidth(19)),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 15,
                          offset: Offset(2, 2),
                          color: Color(0x73D1D9E6)),
                    ],
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(8))),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CollectionDetailPage(index)));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(292),
                        height: ScreenUtil().setWidth(156),
                        decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(
                                ScreenUtil().setWidth(8))),
                        child: ClipRRect(
                            clipBehavior: Clip.antiAlias,
                            borderRadius: BorderRadius.all(
                                Radius.circular(ScreenUtil().setWidth(8))),
                            child: collectionIllustCoverViewer(data['cover'])),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(269),
                        height: ScreenUtil().setWidth(28),
                        margin: EdgeInsets.only(
                          top: ScreenUtil().setWidth(18),
                          bottom: ScreenUtil().setWidth(18),
                          left: ScreenUtil().setWidth(11),
                          right: ScreenUtil().setWidth(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: ScreenUtil().setWidth(107),
                              // height: ScreenUtil().setHeight(28),
                              child: Text(
                                data['title'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: ScreenUtil().setSp(14)),
                              ),
                            ),
                            Container(
                              width: ScreenUtil().setWidth(101),
                              // height: ScreenUtil().setHeight(18),
                              child: collectionTagViewer(data['tagList']),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: ScreenUtil().setWidth(2),
                                      color: Colors.grey[300]),
                                ),
                                child: ClipRRect(
                                    clipBehavior: Clip.antiAlias,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            ScreenUtil().setWidth(25))),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      constraints: BoxConstraints(
                                        minHeight: ScreenUtil().setWidth(25),
                                        minWidth: ScreenUtil().setWidth(25),
                                      ),
                                      child: Image(
                                          image: AdvancedNetworkImage(
                                        prefs.getString('avatarLink'),
                                        useDiskCache: true,
                                        timeoutDuration:
                                            const Duration(seconds: 35),
                                        cacheRule: CacheRule(
                                            maxAge: const Duration(days: 7)),
                                        header: {
                                          'referer': 'https://pixivic.com'
                                        },
                                      )),
                                    )))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  Widget collectionTagViewer(List tagList) {
    String show = '';
    if (tagList.length <= 3) {
      for (int index = 0; index < tagList.length; index++) {
        show += '#${tagList[index]['tagName']}';
      }
    } else if (tagList.length > 3) {
      for (int index = 0; index < 3; index++) {
        show += '#${tagList[index]['tagName']}';
      }
    } else {
      show += ' ';
    }
    return Text(
      show,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: Colors.orange[300],
          fontWeight: FontWeight.w400,
          fontSize: ScreenUtil().setSp(11)),
    );
  }

  Widget collectionIllustCoverViewer(List coverList) {
    if (coverList.length < 3) {
      return Image(
          fit: BoxFit.cover,
          image: AdvancedNetworkImage(
            coverList[0]['medium'],
            useDiskCache: true,
            timeoutDuration: const Duration(seconds: 35),
            cacheRule: CacheRule(maxAge: const Duration(days: 7)),
            header: {'Referer': 'https://app-api.pixiv.net'},
          ));
    } else if (coverList.length < 5) {
      return Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              width: ScreenUtil().setWidth(146),
              height: ScreenUtil().setWidth(156),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[0]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
          Positioned(
              right: 0,
              top: 0,
              width: ScreenUtil().setWidth(146),
              height: ScreenUtil().setWidth(78),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[1]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
          Positioned(
              right: 0,
              bottom: 0,
              width: ScreenUtil().setWidth(146),
              height: ScreenUtil().setWidth(78),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[2]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
        ],
      );
    } else if (coverList.length >= 5) {
      return Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              width: ScreenUtil().setWidth(146),
              height: ScreenUtil().setWidth(156),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[0]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
          Positioned(
              right: 0,
              top: 0,
              width: ScreenUtil().setWidth(73),
              height: ScreenUtil().setWidth(78),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[1]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
          Positioned(
              right: 0,
              bottom: 0,
              width: ScreenUtil().setWidth(73),
              height: ScreenUtil().setWidth(78),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[2]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
          Positioned(
              right: ScreenUtil().setWidth(73),
              bottom: 0,
              width: ScreenUtil().setWidth(73),
              height: ScreenUtil().setWidth(78),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[3]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
          Positioned(
              right: ScreenUtil().setWidth(73),
              top: 0,
              width: ScreenUtil().setWidth(73),
              height: ScreenUtil().setWidth(78),
              child: Image(
                  fit: BoxFit.cover,
                  image: AdvancedNetworkImage(
                    coverList[4]['medium'],
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'Referer': 'https://app-api.pixiv.net'},
                  ))),
        ],
      );
    } else {
      return Container();
    }
    // TODO: else no cover image
  }

  _viewerListener() {
    if (_viewerScrollController.position.extentAfter < 1200 &&
        !Provider.of<CollectionUiModel>(context).onViewerLoad &&
        !Provider.of<CollectionUiModel>(context).onViewerBottom) {
      Provider.of<CollectionUiModel>(context, listen: false)
          .getViewerJsonList();
    }
  }
}
