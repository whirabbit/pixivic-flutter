import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:pixivic/data/common.dart';

import '../widget/papp_bar.dart';
import '../data/texts.dart';
import '../page/user_detail_page.dart';

class CommentListPage extends StatefulWidget {
  @override
  _CommentListPageState createState() => _CommentListPageState();

  CommentListPage(
      {this.comments,
      @required this.illustId,
      this.replyToId = 0,
      this.replyToName = '',
      this.replyParentId = 0,
      this.isReply = false});
  CommentListPage.reply(
      {@required this.comments,
      @required this.illustId,
      @required this.replyToId,
      @required this.replyToName,
      @required this.replyParentId,
      this.isReply = false});

  final List comments;
  final int illustId;
  final int replyToId;
  final String replyToName;
  final int replyParentId;
  final bool isReply;
}

class _CommentListPageState extends State<CommentListPage> {
  TextZhCommentCell texts = TextZhCommentCell();
  ScreenUtil screen = ScreenUtil();
  List commentsList;
  int replyToId;
  String replyToName;
  int replyParentId;
  String hintText;
  TextEditingController textEditingController;
  FocusNode replyFocus;

  @override
  void initState() {
    if (widget.comments != null) commentsList = widget.comments;
    hintText = texts.addCommentHint;
    replyToId = widget.replyToId;
    replyToName = widget.replyToName;
    replyParentId = widget.replyParentId;

    textEditingController = TextEditingController();
    replyFocus = FocusNode()..addListener(_replyFocusListener);

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    replyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          appBar: PappBar(
            title: texts.comment,
          ),
          body: Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                commentsList != null
                    ? Positioned(
                        // top: screen.setHeight(5),
                        child: Container(
                        width: screen.setWidth(324),
                        height: screen.setHeight(576),
                        margin: EdgeInsets.only(bottom: screen.setHeight(35)),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: commentsList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return commentParentCell(commentsList[index]);
                            }),
                      ))
                    : Container(),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: bottomCommentBar(),
                ),
              ],
            ),
          )),
    );
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
              focusNode: replyFocus,
              controller: textEditingController,
              autofocus: widget.isReply ? true : false,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(fontSize: 14),
                  contentPadding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(8),
                      bottom: ScreenUtil().setHeight(9))),
            ),
          ),
          Material(
            child: InkWell(
              child: FaIcon(FontAwesomeIcons.paperPlane),
              onTap: () {
                _reply();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget commentParentCell(Map commentAllData) {
    bool hasSub = commentAllData['subCommentList'] == null ? false : true;

    return Container(
        width: screen.setWidth(324),
        child: Container(
          padding: EdgeInsets.only(
              left: screen.setHeight(7),
              right: screen.setHeight(7),
              top: screen.setHeight(10)),
          alignment: Alignment.topLeft,
          child: Column(
            children: <Widget>[
              commentBaseCell(commentAllData),
              hasSub
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: commentAllData['subCommentList'].length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return commentSubCell(
                            commentAllData['subCommentList'][index]);
                      })
                  : Container(),
              SizedBox(width: screen.setWidth(300), child: Divider())
            ],
          ),
        ));
  }

  Widget commentSubCell(Map commentEachSubData) {
    return Container(
      padding:
          EdgeInsets.only(left: screen.setWidth(15), top: screen.setHeight(7)),
      child: commentBaseCell(commentEachSubData),
    );
  }

  Widget commentBaseCell(Map data) {
    String avaterUrl = 'https://pic.cheerfun.dev/${data['replyFrom']}.png';

    return Container(
        child: Column(children: <Widget>[
      Material(
          color: Colors.white,
          child: InkWell(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    right: ScreenUtil().setWidth(8),
                  ),
                  child: GestureDetector(
                    child: CircleAvatar(
                        // backgroundColor: Colors.white,
                        radius: ScreenUtil().setHeight(14),
                        backgroundImage: NetworkImage(avaterUrl,
                            headers: {'referer': 'https://pixivic.com'})),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return UserDetailPage(
                            data['replyFrom'], data['replyFromName']);
                      }));
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    Text(
                      data['replyFromName'],
                      style: TextStyle(fontSize: 12),
                    ),
                    Container(
                      width: screen.setWidth(235),
                      child: Text(
                        data['replyToName'] == ''
                            ? data['content']
                            : '@${data['replyToName']}: ${data['content']}',
                        softWrap: true,
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
                            DateFormat("yyyy-MM-dd")
                                .format(DateTime.parse(data['createDate'])),
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
                            onTap: () {
                              replyFocus.requestFocus();
                              replyToId = data['replyFrom'];
                              replyToName = data['replyFromName'];
                              replyParentId = data['parentId'];
                            },
                          )
                        ],
                      ),
                    )
                  ],
                )
              ])))
    ]));
  }

  _replyFocusListener() {
    if (replyFocus.hasFocus && replyToName != '') {
      setState(() {
        hintText = '@$replyToName:';
      });
    } else if (!replyFocus.hasFocus && textEditingController.text != '') {
      setState(() {
        replyToId = 0;
        replyToName = '';
        replyParentId = 0;
        hintText = texts.addCommentHint;
        // print(textEditingController.text);
      });
    }
  }

  _reply() async {
    if (prefs.getString('auth') == '') {
      BotToast.showSimpleNotification(title: texts.pleaseLogin);
      return false;
    }

    if (textEditingController.text == '') {
      BotToast.showSimpleNotification(title: texts.commentCannotBeBlank);
      return false;
    }

    String url = 'https://api.pixivic.com/illusts/${widget.illustId}/comments';
    CancelFunc cancelLoading;
    var dio = Dio();
    Map<String, dynamic> payload = {
      'content': textEditingController.text,
      'parentId': replyParentId.toString(),
      'replyFromName': prefs.getString('name'),
      'replyTo': replyToId.toString(),
      'replyToName': replyToName
    };
    Map<String, dynamic> headers = {'authorization': prefs.getString('auth')};
    Response response = await dio.post(
      url,
      data: payload,
      options: Options(headers: headers),
      onReceiveProgress: (count, total) {
        cancelLoading = BotToast.showLoading();
      },
    );
    cancelLoading();
    BotToast.showSimpleNotification(title: response.data['message']);
    if (response.statusCode == 200) {
      textEditingController.text = '';
      replyToId = 0;
      replyToName = '';
      replyParentId = 0;
      await _loadComments();
      return true;
    } else {
      return false;
    }
  }

  _loadComments() async {
    String url = 'https://api.pixivic.com/illusts/${widget.illustId}/comments';
    var dio = Dio();
    Response response = await dio.get(url);
    if (response.statusCode == 200 && response.data['data'] != null) {
      // print(response.data);
      setState(() {
        commentsList = response.data['data'];
      });
    } else {
      BotToast.showSimpleNotification(title: response.data['message']);
    }
  }
}
