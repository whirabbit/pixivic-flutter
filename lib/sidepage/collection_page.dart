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
            return collectionCardCell(
                Provider.of<CollectionUserDataModel>(context)
                    .userCollectionList[index]);
          },
        );
      }
    } else if (mode == CollectionMode.user) {
      return loadingBox();
    } else {
      return loadingBox();
    }
  }

  Widget collectionCardCell(Map data) {
    // TODO: 若无画作则空的图片
    // TODO: 1、3、5的图画格分离
    print(data);
    return Center(
      child: Container(
        width: ScreenUtil().setWidth(292),
        height: ScreenUtil().setHeight(220),
        margin: EdgeInsets.only(
            bottom: ScreenUtil().setHeight(14),
            top: ScreenUtil().setHeight(19)),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 15,
                  offset: Offset(2, 2),
                  color: Color(0x73D1D9E6)),
            ],
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8))),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CollectionDetailPage(data['id'], data['title'])));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(292),
                height: ScreenUtil().setHeight(156),
                decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(8))),
                child: ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScreenUtil().setWidth(8))),
                    child: Image(
                      image: AdvancedNetworkImage(
                        data['cover'][0]['large'],
                        useDiskCache: true,
                        timeoutDuration: const Duration(seconds: 35),
                        cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                        header: {'Referer': 'https://app-api.pixiv.net'},
                      ),
                      fit: BoxFit.cover,
                    )),
              ),
              Container(
                width: ScreenUtil().setWidth(269),
                height: ScreenUtil().setHeight(28),
                margin: EdgeInsets.only(
                  top: ScreenUtil().setHeight(18),
                  bottom: ScreenUtil().setHeight(18),
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
                      // TODO： 对标签个数、长度进行判断
                      child: Text(
                        '#${data['tagList'][0]['tagName']}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.orange[300],
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenUtil().setSp(11)),
                      ),
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
                                Radius.circular(ScreenUtil().setWidth(25))),
                            child: Image(
                                image: AdvancedNetworkImage(
                              prefs.getString('avatarLink'),
                              useDiskCache: true,
                              timeoutDuration: const Duration(seconds: 35),
                              cacheRule:
                                  CacheRule(maxAge: const Duration(days: 7)),
                              header: {'referer': 'https://pixivic.com'},
                            ))))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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
