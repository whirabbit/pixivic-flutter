import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:pixivic/data/texts.dart';
import 'package:pixivic/page/comment_list_page.dart';
import 'package:pixivic/biz/comment/service/comment_service.dart';
import 'package:pixivic/common/config/get_it_config.dart';
import 'package:pixivic/common/do/comment.dart';
import 'package:pixivic/function/dio_client.dart';

class CommentCell extends StatefulWidget {
  @override
  _CommentCellState createState() => _CommentCellState();

  CommentCell(this.id);

  final int id;
}

class _CommentCellState extends State<CommentCell> {
  TextZhCommentCell texts = TextZhCommentCell();
  List<Comment> commentJsonData;
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
      height: ScreenUtil().setHeight(140),
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
        'https://static.pixivic.net/avatar/299x299/${commentJsonData[0].replyFrom}.jpg';
    print(avaterUrl);

    return Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setHeight(7),
          top: ScreenUtil().setHeight(5),
          right: ScreenUtil().setHeight(7)),
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
                        commentJsonData[0].replyFromName,
                        style: TextStyle(fontSize: 12),
                      ),
                      Container(
                          width: ScreenUtil().setWidth(235),
                          alignment: Alignment.centerLeft,
                          child: commentContentDisplay(
                            context,
                            commentJsonData[0].content,
                          )),
                      Container(
                        padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(4),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              DateFormat("yyyy-MM-dd").format(DateTime.parse(
                                  commentJsonData[0].createDate)),
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
                                            replyParentId:
                                                commentJsonData[0].id,
                                            replyToName: commentJsonData[0]
                                                .replyFromName,
                                            replyToId:
                                                commentJsonData[0].replyFrom,
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
            height: ScreenUtil().setHeight(30),
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

  Widget commentContentDisplay(BuildContext context, String content) {
    if (content[0] == '[' &&
        content[content.length - 1] == ']' &&
        content.contains('_:')) {
      String memeStr = content.substring(1, content.length - 1).split('_')[1];
      String memeId = memeStr.substring(1, memeStr.length - 1);
      String memeHead = memeId.split('-')[0];
      print(memeHead);
      print(memeId);
      return Container(
        width: ScreenUtil().setWidth(30),
        height: ScreenUtil().setWidth(30),
        child: Image(image: AssetImage('image/meme/$memeHead/$memeId.webp')),
      );
    } else {
      return Text(
        content,
        softWrap: true,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      );
    }
  }

  _loadCommentData() async {
    String url = '/illusts/${widget.id}/comments';

    try {
      // Response response = await dioPixivic.get(url);
      getIt<CommentService>()
          .queryGetComment(AppType.illusts, widget.id, 1, 10)
          .then((value) {
        if (value != null)
          setState(() {
            commentJsonData = value;
            commentJsonData[0].content =
                commentJsonData[0].content.replaceAll('\n', '');
          });
        // return value.data;
      });

      // if (response.data['data'] != null) {
      //   // print(response.data);
      //   setState(() {
      //     commentJsonData = response.data['data'];
      //     commentJsonData[0]['content'] =
      //         commentJsonData[0]['content'].replaceAll('\n', '');
      //   });
      // }
    } catch (e) {}
  }
}
