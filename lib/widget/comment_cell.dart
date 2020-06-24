import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';

import '../data/common.dart';
import '../data/texts.dart';

class CommentCell extends StatefulWidget {
  @override
  _CommentCellState createState() => _CommentCellState();

  CommentCell(this.id);

  final int id;
}

class _CommentCellState extends State<CommentCell> {
  TextZhCommentCell texts = TextZhCommentCell();
  List jsonData;

  @override
  void initState() {
    _loadCommentData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: ScreenUtil().setWidth(324),
      height: ScreenUtil().setHeight(130),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                left: ScreenUtil().setHeight(7),
                top: ScreenUtil().setHeight(6),
                bottom: ScreenUtil().setHeight(6)),
            child: Text(
              texts.comment,
              style: TextStyle(
                fontSize: ScreenUtil().setWidth(14),
              ),
            ),
          ),
          jsonData == null
              ? Lottie.asset('image/comment.json',
                  repeat: false, height: ScreenUtil().setHeight(40))
              : showFirstComment()
        ],
      ),
    );
  }

  Widget showFirstComment() {
    String avaterUrl =
        'https://pic.cheerfun.dev/${jsonData[0]['replyFrom']}.png';
    print(avaterUrl);
    return Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setHeight(7), top: ScreenUtil().setHeight(5)),
      alignment: Alignment.centerLeft,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  right: ScreenUtil().setWidth(8),
                ),
                child: CircleAvatar(
                    // backgroundColor: Colors.white,
                    radius: ScreenUtil().setHeight(14),
                    backgroundImage: NetworkImage(avaterUrl,
                        headers: {'referer': 'https://pixivic.com'})),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: ScreenUtil().setHeight(5)),
                  Text(
                    jsonData[0]['replyFromName'],
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    jsonData[0]['content'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(4),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          DateFormat("yyyy-MM-dd").format(
                              DateTime.parse(jsonData[0]['createDate'])),
                          strutStyle: StrutStyle(
                            fontSize: 12,
                            height: ScreenUtil().setWidth(1.3),
                          ),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(5),
                        ),
                        GestureDetector(
                          child: Text(
                            texts.reply,
                            strutStyle: StrutStyle(
                              fontSize: 12,
                              height: ScreenUtil().setWidth(1.3),
                            ),
                            style: TextStyle(
                                color: Colors.blue[600], fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(200),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              color: Colors.blueGrey[200],
              child: Text(
                texts.addComment,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  _loadCommentData() async {
    String url = 'https://api.pixivic.com/illusts/${widget.id}/comments';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.data['data'] != null) {
      setState(() {
        jsonData = response.data['data'];
      });
    }
  }
}
