import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pixivic/data/texts.dart';
import 'package:pixivic/provider/collection_model.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/widget/image_display.dart';

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
    _model = CollectionUiModel()..initData();
    _model.getViewerJsonList();
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
            return collectionBody(insdeConetxt);
          }),
        ));
  }

  Widget collectionBody(context) {
    var _collectionData = Provider.of<CollectionUiModel>(context);
    if (_collectionData.viewerList == []) {
      if (!_collectionData.onViewerBottom) {
        return loadingBox();
      } else {
        return nothingHereBox();
      }
    } else if (_collectionData.viewerList != []) {
      return ListView.builder(
        itemCount: _collectionData.viewerList.length,
        itemBuilder: (context, index) {
          return cardCell(_collectionData.viewerList[index]);
        },
      );
    } else {
      return Container();
    }
  }

  Widget cardCell(Map data) {
    print(data);
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      data.keys.contains('cover')
                          ? Image.network(
                              data['cover'][0]['medium'],
                              headers: {'Referer': 'https://app-api.pixiv.net'},
                              fit: BoxFit.fitWidth,
                              width: ScreenUtil().setWidth(300),
                              height: ScreenUtil().setHeight(140),
                            )
                          : Container(height: ScreenUtil().setHeight(70),),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          width: ScreenUtil().setWidth(300),
                          height: ScreenUtil().setHeight(50),
                          color: Colors.black45,
                          padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                          child: Text(
                            data['title'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: ScreenUtil().setWidth(300),
                    height: ScreenUtil().setHeight(40),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            left: ScreenUtil().setWidth(5),
                            top: ScreenUtil().setHeight(7),
                            child: Container(
                              alignment: Alignment.center,
                              // decoration: BoxDecoration(
                              //     color: Colors.blue[300],
                              //     borderRadius: BorderRadius.circular(25)),
                              // width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setHeight(25),
                              child: Text(
                                data['caption'].length > 8
                                    ? '${data['caption'].substring(0, 8)}...'
                                    : data['caption'],
                                style: TextStyle(color: Colors.black54),
                              ),
                            )),
                        Positioned(
                          right: ScreenUtil().setWidth(5),
                          top: ScreenUtil().setHeight(13),
                          child: Text(
                            DateFormat('yyyy-MM-dd')
                                .format(DateTime.parse(data['createTime'])),
                            style:
                                TextStyle(fontSize: ScreenUtil().setHeight(12)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
                child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
              ),
            ))
          ],
        ),
      ),
    );
  }

  _viewerListener() {
    if (_viewerScrollController.position.extentAfter < 1200 &&
        !Provider.of<CollectionUiModel>(context).onViewerLoad &&
        !Provider.of<CollectionUiModel>(context).onViewerBottom) {
      Provider.of<CollectionUiModel>(context, listen: false).getViewerJsonList();
    }
  }
}
