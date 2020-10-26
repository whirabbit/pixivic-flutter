import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:requests/requests.dart' hide Response;
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pixivic/page/pic_page.dart';
import 'package:pixivic/page/artist_page.dart';
import 'package:pixivic/page/search_page.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/widget/bookmark_users.dart';
import 'package:pixivic/widget/comment_cell.dart';
import 'package:pixivic/function/downloadImage.dart';
import 'package:pixivic/function/collection.dart';
import 'package:pixivic/provider/pic_page_model.dart';
import 'package:pixivic/widget/markheart_icon.dart';


class PicDetailPage extends StatefulWidget {
  @override
  _PicDetailPageState createState() => _PicDetailPageState();

  PicDetailPage(this._picData, {this.index, this.getPageProvider});

  final Map _picData;
  final int index;

  final PicPageModel getPageProvider;
}

class _PicDetailPageState extends State<PicDetailPage> {
  bool loginState = prefs.getString('auth') != '' ? true : false;
  int picTotalNum;
  List albumList;
  ScreenUtil screen = ScreenUtil();
  String previewQuality = prefs.getString('previewQuality');
  TextStyle normalTextStyle = TextStyle(
      fontSize: ScreenUtil().setWidth(14),
      color: Colors.black,
      decoration: TextDecoration.none);
  TextStyle smallTextStyle = TextStyle(
      fontSize: ScreenUtil().setWidth(10),
      color: Colors.black,
      decoration: TextDecoration.none);
  TextZhPicDetailPage texts = TextZhPicDetailPage();
  PappBar pappBar;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    print('picDetail Created');
    // print(widget._picData['artistPreView']['isFollowed']);
    picTotalNum = widget._picData['pageCount'];
    _uploadHistory();
    _initPappbar();
    _showUseTips();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: pappBar,
        body: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  // 图片视图
                  Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          color: Colors.white,
                          width: ScreenUtil().setWidth(324),
                          height: ScreenUtil().setWidth(324) /
                              widget._picData['width'] *
                              widget._picData['height'],
                          child: _picBanner(),
                        ),
                      ),
                      // loginState
                      //     ? Positioned(
                      //         bottom: ScreenUtil().setHeight(10),
                      //         right: ScreenUtil().setWidth(20),
                      //         child: _bookmarkHeart(),
                      //       )
                      //     : Container(),
                    ],
                  ),
                  // 标题、爱心、副标题、简介、标签
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                    color: Colors.white,
                    width: ScreenUtil().setWidth(324),
                    // height: ScreenUtil().setHeight(60),
                    alignment: Alignment.centerLeft,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // 标题栏、喜欢爱心
                          Container(
                            width: ScreenUtil().setWidth(324),
                            height: ScreenUtil().setHeight(25),
                            child: Stack(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: SelectableText(
                                    widget._picData['title'],
                                    style: normalTextStyle,
                                  ),
                                ),
                                loginState
                                    ? Positioned(
                                        right: ScreenUtil().setWidth(4),
                                        top: 0,
                                        child: _bookmarkHeart())
                                    : Container(),
                                loginState
                                    ? Positioned(
                                        right: ScreenUtil().setWidth(40),
                                        top: 0,
                                        child: _addToAlbumButton())
                                    : Container(),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(6),
                          ),
                          Html(
                            data: widget._picData['caption'],
                            linkStyle: smallTextStyle,
                            defaultTextStyle: smallTextStyle,
                            onLinkTap: (url) async {
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(6),
                          ),
                          _tags(),
                          SizedBox(
                            height: ScreenUtil().setHeight(6),
                          ),
                        ]),
                  ),
                  // 阅读量、订阅量、时间、关注人
                  Container(
                    // padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                    height: ScreenUtil().setHeight(24),
                    color: Colors.white,
                    width: ScreenUtil().setWidth(324),
                    // alignment: Alignment.centerLeft,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Positioned(
                          left: ScreenUtil().setWidth(10),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.remove_red_eye,
                                size: ScreenUtil().setWidth(10),
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(3),
                              ),
                              Text(
                                widget._picData['totalView'].toString(),
                                style: smallTextStyle,
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(8),
                              ),
                              Icon(
                                Icons.bookmark,
                                size: ScreenUtil().setWidth(10),
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(3),
                              ),
                              Text(
                                widget._picData['totalBookmarks'].toString(),
                                style: smallTextStyle,
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(12),
                              ),
                              Text(
                                widget._picData['createDate'].toString(),
                                style: smallTextStyle,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            right: ScreenUtil().setWidth(10),
                            child: BookmarkUsers(widget._picData['id']))
                      ],
                    ),
                  ),
                  // 作者信息、关注图标
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(13),
                        bottom: ScreenUtil().setWidth(7),
                        right: ScreenUtil().setWidth(7),
                        left: ScreenUtil().setWidth(7)),
                    color: Colors.white,
                    width: ScreenUtil().setWidth(324),
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      children: <Widget>[
                        // 作者头像
                        Positioned(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return ArtistPage(
                                          widget._picData['artistPreView']
                                              ['avatar'],
                                          widget._picData['artistPreView']
                                              ['name'],
                                          widget._picData['artistPreView']['id']
                                              .toString(),
                                          isFollowed: loginState
                                              ? widget._picData['artistPreView']
                                                  ['isFollowed']
                                              : false,
                                          followedRefresh: _followedRefresh);
                                    },
                                  ));
                                },
                                child: Hero(
                                  tag: widget._picData['artistPreView']
                                      ['avatar'],
                                  child: CircleAvatar(
                                    backgroundImage: AdvancedNetworkImage(
                                      widget._picData['artistPreView']
                                          ['avatar'],
                                      header: {
                                        'Referer': 'https://app-api.pixiv.net'
                                      },
                                      useDiskCache: true,
                                      cacheRule: CacheRule(
                                          maxAge: Duration(
                                              days:
                                                  prefs.getInt('previewRule'))),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(10),
                              ),
                              Text(
                                widget._picData['artistPreView']['name'],
                                style: smallTextStyle,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: ScreenUtil().setWidth(5),
                          bottom: ScreenUtil().setHeight(-2),
                          child: loginState ? _subscribeButton() : Container(),
                        )
                      ],
                    ),
                  ),
                  // 评论模块
                  Container(
                    child: CommentCell(
                      widget._picData['id'],
                    ),
                  ),
                  // 相关作品
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setHeight(7)),
                    color: Colors.white,
                    width: ScreenUtil().setWidth(324),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '相关作品',
                      style: normalTextStyle,
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Container(
                width: ScreenUtil().setWidth(324),
                height: ScreenUtil().setHeight(485),
                color: Colors.white,
                child: PicPage.related(
                  relatedId: widget._picData['id'],
                  onPageTop: _onTopOfPicpage,
                  onPageStart: _onStartOfPicpage,
                  isScrollable: true,
//                  funOne: true,
                ),
              ),
            ),
          ],
        ));
//      ),
  }

  Widget _picBanner() {
    // 图片滚动条
    if (picTotalNum == 1) {
      return GestureDetector(
        onLongPress: () {
          _longPressPic(widget._picData['imageUrls'][0]['original']);
        },
        child: Hero(
            tag: 'imageHero' + widget._picData['imageUrls'][0][previewQuality],
            //medium large, set tag as medium for hero switch,
            child: ZoomableWidget(
              panLimit: 1.0,
              maxScale: 3.0,
              minScale: 0.7,
              child: TransitionToImage(
                image: AdvancedNetworkImage(
                  widget._picData['imageUrls'][0][previewQuality],
                  header: {'Referer': 'https://app-api.pixiv.net'},
                  useDiskCache: true,
                  cacheRule: CacheRule(
                      maxAge: Duration(days: prefs.getInt('previewRule'))),
                ),
                width: ScreenUtil().setWidth(324),
                height: ScreenUtil().setWidth(324) /
                    widget._picData['width'] *
                    widget._picData['height'],
                placeholder: CircularProgressIndicator(),
              ),
            )),
      );
    } else if (picTotalNum > 1) {
      return Swiper(
        pagination: SwiperPagination(),
        control: SwiperControl(),
        itemCount: picTotalNum,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              _longPressPic(widget._picData['imageUrls'][index]['original']);
            },
            child: Hero(
                tag: 'imageHero' +
                    widget._picData['imageUrls'][index]
                        ['medium'], //medium large
                child: ZoomableWidget(
                  panLimit: 1.0,
                  maxScale: 3.0,
                  minScale: 0.7,
                  child: TransitionToImage(
                    image: AdvancedNetworkImage(
                      widget._picData['imageUrls'][index][previewQuality],
                      header: {'Referer': 'https://app-api.pixiv.net'},
                      useDiskCache: true,
                      cacheRule: CacheRule(
                          maxAge: Duration(days: prefs.getInt('previewRule'))),
                    ),
                    width: ScreenUtil().setWidth(324),
                    height: ScreenUtil().setWidth(324) /
                        widget._picData['width'] *
                        widget._picData['height'],
                    placeholder: CircularProgressIndicator(),
                  ),
                )),
          );
        },
      );
    } else {
      return Text('网络错误，请检查网络');
    }
  }

  Widget _tags() {
    TextStyle translateTextStyle = TextStyle(
        fontSize: ScreenUtil().setWidth(8),
        color: Colors.black,
        decoration: TextDecoration.none);
    TextStyle tagTextStyle = TextStyle(
        fontSize: ScreenUtil().setWidth(8),
        color: Colors.blue[300],
        decoration: TextDecoration.none);
    StrutStyle strutStyle = StrutStyle(
      fontSize: ScreenUtil().setWidth(8),
      height: ScreenUtil().setWidth(1.3),
    );
    List tags = widget._picData['tags'];
    List<Widget> tagsRow = [];

    for (var item in tags) {
      tagsRow.add(GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SearchPage(searchKeywordsIn: item['name'])));
          },
          child: Text(
            '#${item['name']}',
            style: tagTextStyle,
            strutStyle: strutStyle,
          )));
      tagsRow.add(SizedBox(
        width: ScreenUtil().setWidth(4),
      ));
      if (item['translatedName'] != '') {
        tagsRow.add(Text(
          item['translatedName'],
          style: translateTextStyle,
          strutStyle: strutStyle,
        ));
        tagsRow.add(SizedBox(
          width: ScreenUtil().setWidth(4),
        ));
      }
    }

    return Wrap(
      children: tagsRow,
    );
  }

  Widget _subscribeButton() {
    bool currentFollowedState = widget._picData['artistPreView']['isFollowed'];
    String buttonText = currentFollowedState ? texts.followed : texts.follow;

    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      color: Colors.blueAccent[200],
      onPressed: () async {
        String url = 'https://api.pixivic.com/users/followed';
        Map<String, String> body = {
          'artistId': widget._picData['artistPreView']['id'].toString(),
          'userId': prefs.getInt('id').toString(),
          'username': prefs.getString('name'),
        };
        Map<String, String> headers = {
          'authorization': prefs.getString('auth')
        };
        try {
          if (currentFollowedState) {
            var r = await Requests.delete(url,
                body: body,
                headers: headers,
                bodyEncoding: RequestBodyEncoding.JSON);
            r.raiseForStatus();
          } else {
            var r = await Requests.post(url,
                body: body,
                headers: headers,
                bodyEncoding: RequestBodyEncoding.JSON);
            r.raiseForStatus();
          }
          setState(() {
            widget._picData['artistPreView']['isFollowed'] =
                !widget._picData['artistPreView']['isFollowed'];
          });
        } catch (e) {
          print(e);
          // print(homePicList[widget.index]['artistPreView']['isFollowed']);
          BotToast.showSimpleNotification(title: texts.followError);
        }
      },
      child: Text(
        buttonText,
        style:
            TextStyle(fontSize: ScreenUtil().setWidth(10), color: Colors.white),
      ),
    );
  }

  Widget _bookmarkHeart() {
    return Container(
        alignment: Alignment.center,
        height: ScreenUtil().setWidth(28),
        width: ScreenUtil().setWidth(28),
//      height: isLikedLocalState
//          ? ScreenUtil().setWidth(28)
//          : ScreenUtil().setWidth(25),
//      width: isLikedLocalState
//          ? ScreenUtil().setWidth(28)
//          : ScreenUtil().setWidth(25),
        child: MarkHeart(
            picItem: widget._picData,
            index: widget.index,
            getPageProvider: widget.getPageProvider));
  }

  Widget _addToAlbumButton() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      width: ScreenUtil().setWidth(28),
      height: ScreenUtil().setWidth(28),
      child: Material(
        color: Colors.white,
        child: InkWell(
          child: FaIcon(
            FontAwesomeIcons.folderPlus,
            color: Colors.blueGrey,
          ),
          onTap: () {
            showAddToCollection(context, [widget._picData['id']]);
          },
        ),
      ),
    );
  }

  

  _longPressPic(String url) async {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext buildContext) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text(texts.downloadImage),
                  leading: Icon(
                    Icons.cloud_download,
                    color: Colors.orangeAccent,
                  ),
                  onTap: () async {
                    final String platform =
                        Theme.of(context).platform == TargetPlatform.android
                            ? 'android'
                            : 'ios';
                    _checkPermission().then((value) async {
                      if (value) {
                        DownloadImage(url, platform);
                      } else {
                        BotToast.showSimpleNotification(
                            title: texts.requestDownloadAuthority);
                      }
                    });

                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(texts.jumpToPixivDetail),
                  leading: Icon(Icons.image, color: Colors.purple),
                  onTap: () async {
                    String url =
                        'https://pixiv.net/artworks/${widget._picData['id']}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(texts.jumpToPixivArtist),
                  leading: Icon(
                    Icons.people,
                    color: Colors.blueAccent,
                  ),
                  onTap: () async {
                    String url =
                        'https://pixiv.net/users/${widget._picData['artistId']}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                    Navigator.of(context).pop();
                    // Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(texts.copyArtistId),
                  leading: Icon(
                    Icons.confirmation_number,
                    color: Colors.red[300],
                  ),
                  onTap: () async {
                    Clipboard.setData(ClipboardData(
                        text: widget._picData['artistId'].toString()));
                    BotToast.showSimpleNotification(title: texts.alreadyCopied);
                    Navigator.of(context).pop();
                    // Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(texts.copyIllustId),
                  leading: Icon(
                    Icons.confirmation_number,
                    color: Colors.green[300],
                  ),
                  onTap: () async {
                    Clipboard.setData(
                        ClipboardData(text: widget._picData['id'].toString()));
                    BotToast.showSimpleNotification(title: texts.alreadyCopied);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  // 检查是否获取足够的系统权限
  Future<bool> _checkPermission() async {
    // TODO: check for ios china version internet permission
    if (Theme.of(context).platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  // 同步关注状态
  _followedRefresh(bool result) {
    setState(() {
      widget._picData['artistPreView']['isFollowed'] = result;
    });
  }

  // 留下查看图片的痕迹
  _uploadHistory() async {
    if (prefs.getString('auth') != '') {
      String url =
          'https://api.pixivic.com/users/${widget._picData['id'].toString()}/illustHistory';
      Map<String, String> headers = {'authorization': prefs.getString('auth')};
      Map<String, String> body = {
        'userId': prefs.getInt('id').toString(),
        'illustId': widget._picData['id'].toString()
      };
      await Requests.post(url,
          headers: headers, body: body, bodyEncoding: RequestBodyEncoding.JSON);
    }
  }

  _onTopOfPicpage() {
    double position =
        scrollController.position.extentBefore - ScreenUtil().setHeight(450);
    scrollController.animateTo(position,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  _onStartOfPicpage() {
    double position =
        scrollController.position.extentBefore + ScreenUtil().setHeight(350);
    scrollController.animateTo(position,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  _initPappbar() {
    String tempTitle = widget._picData['title'];
    tempTitle.length > 20
        ? tempTitle = tempTitle.substring(0, 20) + '...'
        : tempTitle = tempTitle;
    pappBar = PappBar(title: tempTitle);
  }

  _showUseTips() {
    if (!prefs.getBool('isBackTipsKnown'))
      BotToast.showAttachedWidget(
          attachedBuilder: (CancelFunc cancel) => Card(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FaIcon(
                        FontAwesomeIcons.handPointLeft,
                        color: Colors.purple[100],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('按住屏幕边缘右滑\n返回上一个页面'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                            child: Text(
                              '不再提醒',
                              style: TextStyle(color: Colors.red[200]),
                            ),
                            onTap: () {
                              prefs.setBool('isBackTipsKnown', true);
                              cancel();
                            }),
                      ),
                    ),
                  ],
                ),
              ),
          duration: Duration(seconds: 10),
          target:
              Offset(ScreenUtil().setWidth(10), ScreenUtil().setHeight(250)));

    if (!prefs.getBool('isPicTipsKnown'))
      BotToast.showAttachedWidget(
          attachedBuilder: (CancelFunc cancel) => Card(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FaIcon(
                        FontAwesomeIcons.handPointDown,
                        color: Colors.blue[200],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('试试长按图片\n和双指捏合图片'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                            child: Text(
                              '不再提醒',
                              style: TextStyle(color: Colors.red[200]),
                            ),
                            onTap: () {
                              prefs.setBool('isPicTipsKnown', true);
                              cancel();
                            }),
                      ),
                    ),
                  ],
                ),
              ),
          duration: Duration(seconds: 10),
          target:
              Offset(ScreenUtil().setWidth(180), ScreenUtil().setHeight(150)));
  }
}
