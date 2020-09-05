import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/texts.dart';
import '../provider/collection_model.dart';
import '../widget/papp_bar.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  CollectionModel _model;
  ScrollController _viewerScrollController;

  @override
  void initState() {
    _model = CollectionModel()..initData();
    _viewerScrollController = ScrollController()..addListener(_viewerListener);
    Provider.of<CollectionModel>(context, listen: false).initData();
    Provider.of<CollectionModel>(context, listen: false).getViewerJsonList();
    super.initState();
  }

  @override
  void dispose() {
    Provider.of<CollectionModel>(context, listen: false).resetViewer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PappBar(title: '画集'),
        body: ChangeNotifierProvider.value(
            value: _model,
            child: ));
  }

  Widget cardCell(Map data) {
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
                      Image.network(
                        data['cover']['imageUrls']['large'],
                        headers: {'Referer': 'https://app-api.pixiv.net'},
                        fit: BoxFit.fitWidth,
                        width: ScreenUtil().setWidth(300),
                        height: ScreenUtil().setHeight(140),
                      ),
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
                              decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(25)),
                              width: ScreenUtil().setWidth(50),
                              height: ScreenUtil().setHeight(25),
                              child: Text(
                                data['caption'],
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        Positioned(
                          right: ScreenUtil().setWidth(5),
                          top: ScreenUtil().setHeight(13),
                          child: Text(
                            data['createTime'],
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
        !Provider.of<CollectionModel>(context).onViewerLoad &&
        !Provider.of<CollectionModel>(context).onViewerBottom) {
      Provider.of<CollectionModel>(context, listen: false).getViewerJsonList();
    }
  }
}
