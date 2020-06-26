import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';

import '../data/common.dart';
import '../data/texts.dart';
import '../page/comment_list_page.dart';

class CommentCell extends StatefulWidget {
  @override
  _CommentCellState createState() => _CommentCellState();

  CommentCell(this.id);

  final int id;
}

class _CommentCellState extends State<CommentCell> {
  TextZhCommentCell texts = TextZhCommentCell();
  List commentJsonData;
  CommentListPage commentListPage;

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
          commentJsonData == null ? showNoComment() : showFirstComment()
        ],
      ),
    );
  }

  Widget showNoComment() {
    return Column(
      children: <Widget>[
        Lottie.asset('image/comment.json',
            repeat: false, height: ScreenUtil().setHeight(45)),
        SizedBox(
          height: ScreenUtil().setHeight(12),
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => CommentListPage(
                          comments: null,
                          illustId: widget.id,
                          isReply: true,
                        )),
              );
            },
          ),
        )
      ],
    );
  }

  Widget showFirstComment() {
    String avaterUrl =
        'https://pic.cheerfun.dev/${commentJsonData[0]['replyFrom']}.png';
    return Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setHeight(7), top: ScreenUtil().setHeight(5), right: ScreenUtil().setHeight(7)), 
      alignment: Alignment.centerLeft,
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.white,
            child: InkWell(
              // 跳转总回复
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => CommentListPage(
                            comments: commentJsonData,
                            illustId: widget.id,
                          )),
                );
              },
              child: Row(
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
                        commentJsonData[0]['replyFromName'],
                        style: TextStyle(fontSize: 12),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(235),
                        child: Text(
                          commentJsonData[0]['content'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(4),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              DateFormat("yyyy-MM-dd").format(DateTime.parse(
                                  commentJsonData[0]['createDate'])),
                              strutStyle: StrutStyle(
                                fontSize: 12,
                                height: ScreenUtil().setWidth(1.3),
                              ),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            SizedBox(
                              width: ScreenUtil().setWidth(5),
                            ),
                            // 回复
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
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CommentListPage.reply(
                                            comments: commentJsonData,
                                            illustId: widget.id,
                                            isReply: true,
                                            replyParentId: commentJsonData[0]['id'],
                                            replyToName: commentJsonData[0]
                                                ['replyFromName'],
                                            replyToId: commentJsonData[0]
                                                ['replyFrom'],
                                          )),
                                );
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(5),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => CommentListPage(
                            comments: commentJsonData,
                            illustId: widget.id,
                            isReply: true,
                          )),
                );
              },
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
      // print(response.data);
      setState(() {
        commentJsonData = response.data['data'];
        commentJsonData[0]['content'] =
            commentJsonData[0]['content'].replaceAll('\n', '');
      });
    }
  }
}
