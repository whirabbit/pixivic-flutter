import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/texts.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }

  Widget cardCell(int index) {
    Map data = spotlightList[index];
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
                        data['thumbnail'],
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
                                data['subcategoryLabel'],
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        Positioned(
                          right: ScreenUtil().setWidth(5),
                          top: ScreenUtil().setHeight(13),
                          child: Text(
                            data['publishDate'],
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
                onTap: () {
                  
                },
              ),
            ))
          ],
        ),
      ),
    );
  }
}