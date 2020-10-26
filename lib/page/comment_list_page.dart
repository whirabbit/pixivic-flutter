import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:pixivic/provider/comment_list_model.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/page/user_detail_page.dart';

class CommentListPage extends StatelessWidget {
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

  final TextZhCommentCell texts = TextZhCommentCell();
  final ScreenUtil screen = ScreenUtil();

//  List commentsList;
//  int replyToId;
//  int currentPage = 1;
//  String replyToName;
//  int replyParentId;
//  String hintText;
//  bool loadMoreAble = true;
//  TextEditingController textEditingController;
//  FocusNode replyFocus;
//  ScrollController scrollController;
// CommentListModel commentProvider;

//  @override
//  void initState() {
////    if (widget.comments != null) commentsList = widget.comments;
////    hintText = texts.addCommentHint;
////    replyToId = widget.replyToId;
////    replyToName = widget.replyToName;
////    replyParentId = widget.replyParentId;
//
////    textEditingController = TextEditingController();
////    replyFocus = FocusNode()..addListener(_replyFocusListener);
////    scrollController = ScrollController()..addListener(_altLoading);
////    _loadComments();
//
//    super.initState();
//  }

//  @override
//  void dispose() {
////    textEditingController.dispose();
////    replyFocus.dispose();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //收键盘
        FocusScope.of(context).requestFocus(FocusNode());
//        FocusScopeNode currentFocus = FocusScope.of(context);
//
//        if (!currentFocus.hasPrimaryFocus) {
//          currentFocus.unfocus();
//        }
      },
      child: Scaffold(
        appBar: PappBar(
          title: texts.comment,
        ),
        body: ChangeNotifierProvider<CommentListModel>(
          create: (_) =>
              CommentListModel(illustId, replyToId, replyToName, replyParentId),
          child: Selector<CommentListModel, CommentListModel>(
            shouldRebuild: (pre, next) => false,
            selector: (context, provider) => provider,
            builder: (context, CommentListModel commentProvider, _) {
//              this.commentProvider = commentProvider;
//              if (commentProvider.commentList == null) {
//                commentProvider.loadComments(widget.illustId);
//                commentProvider.commentList = [];
//                commentsList = [];
//              }
//              commentsList = commentsList + commentProvider.commentList;
              return Container(
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Selector<CommentListModel, List>(
                        selector: (context, provider) => provider.commentList,
                        builder: (context, commentList, _) {
                          return commentList != null
                              ? Positioned(
                                  // top: screen.setHeight(5),
                                  child: Container(
                                  width: screen.setWidth(324),
                                  height: screen.setHeight(576),
                                  margin: EdgeInsets.only(
                                      bottom: screen.setHeight(35)),
                                  child: ListView.builder(
                                      controller:
                                          commentProvider.scrollController,
                                      shrinkWrap: true,
                                      itemCount:
                                          commentProvider.commentList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        //TODO 解决参数传递问题
                                        return commentParentCell(
                                            commentList[index],
                                            context,
                                            commentProvider);
                                      }),
                                ))
                              : Container();
                        }),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: bottomCommentBar(commentProvider),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget bottomCommentBar(CommentListModel commentProvider) {
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
              child: Selector<CommentListModel, String>(
                selector: (context, provider) => provider.hintText,
                builder: (context, hintString, _) {
                  return TextField(
                    focusNode: commentProvider.replyFocus,
                    controller: commentProvider.textEditingController,
                    autofocus: isReply ? true : false,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hintString,
                        hintStyle: TextStyle(fontSize: 14),
                        contentPadding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(8),
                            bottom: ScreenUtil().setHeight(9))),
                  );
                },
              )),
          Material(
            child: InkWell(
              child: FaIcon(FontAwesomeIcons.paperPlane),
              onTap: () {
                commentProvider.reply();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget commentParentCell(
      Map commentAllData, BuildContext context, commentProvider) {
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
              commentBaseCell(commentAllData, context, commentProvider),
              hasSub
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: commentAllData['subCommentList'].length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return commentSubCell(
                            commentAllData['subCommentList'][index],
                            context,
                            commentProvider);
                      })
                  : Container(),
              SizedBox(width: screen.setWidth(300), child: Divider())
            ],
          ),
        ));
  }

  Widget commentSubCell(
      Map commentEachSubData, BuildContext context, commentProvider) {
    return Container(
      padding:
          EdgeInsets.only(left: screen.setWidth(15), top: screen.setHeight(7)),
      child: commentBaseCell(commentEachSubData, context, commentProvider),
    );
  }

  Widget commentBaseCell(Map data, BuildContext context, commentProvider) {
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
                              commentProvider.replyToId = data['replyFrom'];
                              commentProvider.replyToName =
                                  data['replyFromName'];
                              data['parentId'] == 0
                                  ? commentProvider.replyParentId = data['id']
                                  : commentProvider.replyParentId =
                                      data['parentId'];
                              if (commentProvider.replyFocus.hasFocus)
                                commentProvider.replyFocusListener();
                              else
                                commentProvider.replyFocus.requestFocus();
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

//  _altLoading() {
//    if ((scrollController.position.extentAfter < 500) && loadMoreAble) {
//      print(" Load Comment");
//      loadMoreAble = false;
//      currentPage++;
//      print('current page is $currentPage');
//      try {
//        commentProvider
//            .loadComments(widget.illustId, page: currentPage)
//            .then((value) {
//          if (value.length != 0) {
//            loadMoreAble = true;
//          }
//        });
//      } catch (err) {
//        print('=========getJsonList==========');
//        print(err);
//        print('==============================');
//        if (err.toString().contains('SocketException'))
//          BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
//        loadMoreAble = true;
//      }
//    }
//  }

//  _replyFocusListener() {
//    if (replyFocus.hasFocus && replyToName != '') {
//      print('on focus');
//      setState(() {
//        hintText = '@$replyToName:';
//      });
//    } else if (!replyFocus.hasFocus) {
//      print('focus released');
//      setState(() {
//      replyToId = 0;
//      replyToName = '';
//      replyParentId = 0;
//      hintText = texts.addCommentHint;
//      // print(textEditingController.text);
//      });
//    }
//    print('replyParentId now is $replyParentId');
//  }

//  _reply() async {
//    if (prefs.getString('auth') == '') {
//      BotToast.showSimpleNotification(title: texts.pleaseLogin);
//      return false;
//    }
//
//    if (commentProvider.textEditingController.text == '') {
//      BotToast.showSimpleNotification(title: texts.commentCannotBeBlank);
//      return false;
//    }
//
//    String url = 'https://api.pixivic.com/illusts/${widget.illustId}/comments';
//    CancelFunc cancelLoading;
//    var dio = Dio();
//    Map<String, dynamic> payload = {
//      'content': commentProvider.textEditingController.text,
//      'parentId': commentProvider.replyParentId.toString(),
//      'replyFromName': prefs.getString('name'),
//      'replyTo': commentProvider.replyToId.toString(),
//      'replyToName': commentProvider.replyToName
//    };
//    Map<String, dynamic> headers = {'authorization': prefs.getString('auth')};
//    Response response = await dio.post(
//      url,
//      data: payload,
//      options: Options(headers: headers),
//      onReceiveProgress: (count, total) {
//        cancelLoading = BotToast.showLoading();
//      },
//    );
//    cancelLoading();
//    BotToast.showSimpleNotification(title: response.data['message']);
//    if (response.statusCode == 200) {
//      commentProvider.textEditingController.text = '';
//      commentProvider.replyToId = 0;
//      commentProvider.replyToName = '';
//      commentProvider.replyParentId = 0;
//      commentProvider.loadComments(widget.illustId);
////      await _loadComments();
//      return true;
//    } else {
//      return false;
//    }
//  }

//  _loadComments() async {
//    String url = 'https://api.pixivic.com/illusts/${widget.illustId}/comments';
//    var dio = Dio();
//    Response response = await dio.get(url);
//    if (response.statusCode == 200 && response.data['data'] != null) {
//      // print(response.data);
//      setState(() {
//        commentsList = response.data['data'];
//      });
//    } else if (response.statusCode == 200 && response.data['data'] == null) {
//      print('comments: null but 200');
//    } else {
//      BotToast.showSimpleNotification(title: response.data['message']);
//    }
//  }
}
