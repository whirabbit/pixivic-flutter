import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widget/papp_bar.dart';
import '../data/texts.dart';

class CommentListPage extends StatefulWidget {
  @override
  _CommentListPageState createState() => _CommentListPageState();

  CommentListPage(
      {@required this.comments,
      @required this.illustId,
      this.replyToId,
      this.replyToName,
      this.parentId,
      this.isReply = false});
  CommentListPage.reply(
      {@required this.comments,
      @required this.illustId,
      @required this.replyToId,
      @required this.replyToName,
      @required this.parentId,
      this.isReply = false});

  final List comments;
  final int illustId;
  final int replyToId;
  final String replyToName;
  final int parentId;
  final bool isReply;
}

class _CommentListPageState extends State<CommentListPage> {
  TextZhCommentCell texts = TextZhCommentCell();
  ScreenUtil screen = ScreenUtil();
  List commentsList;
  int replyToId;
  String replyToName;

  @override
  void initState() {
    commentsList = widget.comments;
    replyToId = widget.replyToId;
    replyToName = widget.replyToName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PappBar(
          title: texts.comment,
        ),
        body: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: bottomCommentBar(),
            )
          ],
        ));
  }

  _loadComments() async {
    String url = 'https://api.pixivic.com/illusts/${widget.illustId}/comments';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.data['data'] != null) {
      print(response.data);
      setState(() {
        commentsList = response.data['data'];
      });
    }
  }

  Widget bottomCommentBar() {
    return Container(
      padding: EdgeInsets.only(bottom: screen.setHeight(5)),
      width: screen.setWidth(324),
      height: screen.setHeight(35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(260),
            height: ScreenUtil().setHeight(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFFF4F3F3F3),
            ),
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(13),
              right: ScreenUtil().setWidth(12),
            ),
            child: TextField(
              autofocus: widget.isReply ? true : false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: texts.addCommentHint,
                  hintStyle: TextStyle(fontSize: 14),
                  contentPadding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(8),
                      bottom: ScreenUtil().setHeight(9))),
            ),
          ),
          Material(
            child: InkWell(
              child: FaIcon(FontAwesomeIcons.paperPlane),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget commentParentCell(Map commentAllData) {
    return Container();
  }

  Widget commentSubCell(Map commentEachSubData) {
    return Container();
  }
}
