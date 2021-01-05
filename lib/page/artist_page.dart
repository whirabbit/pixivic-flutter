import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/page/pic_page.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/biz/artist/service/artist_detail_service.dart';
import 'package:pixivic/common/config/get_it_config.dart';
import 'package:pixivic/common/do/artist_detail.dart';

class ArtistPage extends StatefulWidget {
  @override
  _ArtistPageState createState() => _ArtistPageState();

  ArtistPage(this.artistAvatar, this.artistName, this.artistId,
      {this.isFollowed, this.followedRefresh});

  final String artistAvatar;
  final String artistName;
  final String artistId;
  final bool isFollowed;
  final Function(bool) followedRefresh;
}

class _ArtistPageState extends State<ArtistPage> {
  bool loginState = prefs.getString('auth') != '' ? true : false;
  TextZhArtistPage texts = TextZhArtistPage();
  bool isFollowed;
  ScrollController scrollController = ScrollController();
  PappBar pappBar;

  TextStyle smallTextStyle = TextStyle(
      fontSize: ScreenUtil().setWidth(10),
      color: Colors.black,
      decoration: TextDecoration.none);
  TextStyle normalTextStyle = TextStyle(
      fontSize: ScreenUtil().setWidth(14),
      color: Colors.black,
      decoration: TextDecoration.none);

  String numOfFollower = '';
  String numOfBookmarksPublic = '';
  String numOfIllust = '0';
  String numOfManga = '0';
  String comment = '';
  String urlTwitter = '';
  String urlWebPage = '';
  List<Tab> tabs;
  bool isDataLoaded;

  @override
  void initState() {
    isDataLoaded = false;
    isFollowed = widget.isFollowed;
    _initPappbar();
    _loadArtistData().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: pappBar,
      body: artistPageBody(),
    );
  }

  Widget artistPageBody() {
    return !isDataLoaded
        ? Container(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(30)),
            alignment: Alignment.center,
            color: Colors.white,
            child: Center(
              child: Column(
                children: <Widget>[
                  Hero(
                    tag: widget.artistAvatar,
                    child: CircleAvatar(
                      backgroundImage: AdvancedNetworkImage(
                        widget.artistAvatar,
                        header: {'Referer': 'https://app-api.pixiv.net'},
                        useDiskCache: true,
                        cacheRule: CacheRule(
                            maxAge:
                                Duration(days: prefs.getInt('previewRule'))),
                      ),
                    ),
                  ),
                  Lottie.asset('image/loading-box.json'),
                ],
              ),
            ))
        : Container(
            color: Colors.white,
            child: ListView(
              controller: scrollController,
              shrinkWrap: true,
              children: <Widget>[
                // 头像、名称、关注按钮
                Container(
                    padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
                    margin: EdgeInsets.all(ScreenUtil().setHeight(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: widget.artistAvatar,
                          child: CircleAvatar(
                            backgroundImage: AdvancedNetworkImage(
                              widget.artistAvatar,
                              header: {'Referer': 'https://app-api.pixiv.net'},
                              useDiskCache: true,
                              cacheRule: CacheRule(
                                  maxAge: Duration(
                                      days: prefs.getInt('previewRule'))),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                        ),
                        Text(
                          widget.artistName,
                          style: normalTextStyle,
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(10),
                        ),
                        GestureDetector(
                          child: Text('ID:${widget.artistId}',
                              style: smallTextStyle),
                          onLongPress: () {
                            Clipboard.setData(ClipboardData(
                                text: widget.artistId.toString()));
                            BotToast.showSimpleNotification(
                                title: texts.alreadyCopied);
                          },
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(25),
                        ),
                        loginState ? _subscribeButton() : Container(),
                      ],
                    )),
                // 个人网站和 Twitter
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setHeight(0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () async {
                            if (await canLaunch(urlWebPage)) {
                              await launch(urlWebPage);
                            } else {
                              BotToast.showSimpleNotification(title: '唤起网页失败');
                              throw 'Could not launch $urlWebPage';
                            }
                          },
                          child: FaIcon(
                            FontAwesomeIcons.home,
                            color: Colors.blue,
                          )),
                      SizedBox(
                        width: ScreenUtil().setWidth(8),
                      ),
                      GestureDetector(
                          onTap: () async {
                            if (await canLaunch(urlTwitter)) {
                              await launch(urlTwitter);
                            } else {
                              BotToast.showSimpleNotification(title: '唤起网页失败');
                              throw 'Could not launch $urlTwitter';
                            }
                          },
                          child: FaIcon(
                            FontAwesomeIcons.twitterSquare,
                            color: Colors.blue,
                          ))
                    ],
                  ),
                ),
                // 关注人数
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
                  child: (Text(
                    '$numOfFollower 关注',
                    style: smallTextStyle,
                  )),
                ),
                // 简介
                Container(
                  margin: EdgeInsets.all(ScreenUtil().setHeight(20)),
                  child: Wrap(
                    children: <Widget>[
                      Text(
                        '$comment',
                        style: smallTextStyle,
                      ),
                    ],
                  ),
                ),
                // 相关图片
                Container(
                  height: ScreenUtil().setHeight(521),
                  width: ScreenUtil().setWidth(324),
                  child: _tabViewer(),
                )
              ],
            ),
          );
  }

  _loadArtistData() async {
    String urlId = '/artists/${widget.artistId}';
    String urlSummary = '/artists/${widget.artistId}/summary';
    Response response;
    try {
      getIt<ArtistDetailService>()
          .queryArtistInfo(int.parse(widget.artistId))
          .then((result) {
        ArtistDetail artistDetail = result.data;
        print(artistDetail);
        this.comment = artistDetail.comment;
        this.urlTwitter = artistDetail.twitterUrl;
        this.urlWebPage = artistDetail.webPage;
        this.numOfBookmarksPublic = artistDetail.totalIllustBookmarksPublic;
        this.numOfFollower = artistDetail.totalFollowUsers;
      });
    } catch (e) {
      if (e.response.statusCode == 401) {
        BotToast.showSimpleNotification(title: texts.needLogin);
        isDataLoaded = false;
        return false;
      } else {
        BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
        isDataLoaded = false;
        return ('finished');
      }
    }

    try {
      response = await dioPixivic.get(
        urlSummary,
      );
      var jsonList = response.data['data'];
      this.numOfIllust = jsonList['illustSum'].toString();
      this.numOfManga = jsonList['mangaSum'].toString();
      this.tabs = <Tab>[
        Tab(
          text: '插画(${this.numOfIllust})',
        ),
        Tab(
          text: '漫画(${this.numOfManga})',
        ),
      ];
      isDataLoaded = true;
    } catch (e) {
      BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
      isDataLoaded = false;
      return ('finished');
    }
  }

  _onTopOfPicpage() {
    double position =
        scrollController.position.extentBefore - ScreenUtil().setHeight(350);
    scrollController.animateTo(position,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  _onStartOfPicpage() {
    double position =
        scrollController.position.extentBefore + ScreenUtil().setHeight(550);
    scrollController.animateTo(position,
        duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  Widget _tabViewer() {
    // 初始化时 tabs 为 null，获取结果后被赋值
    if (tabs != null) {
      return DefaultTabController(
        length: 2,
        child: Stack(
          children: <Widget>[
            Material(
                child: Container(
                    height: ScreenUtil().setHeight(30),
                    child: TabBar(
                      labelColor: Colors.blueAccent[200],
                      tabs: tabs,
                    ))),
            Positioned(
              top: ScreenUtil().setHeight(30),
              child: Container(
                height: ScreenUtil().setHeight(491),
                width: ScreenUtil().setWidth(324),
                child: TabBarView(
                  children: tabs.map((Tab tab) {
                    return PicPage.artist(
//                      funOne: true,
                      artistId: widget.artistId,
                      isManga: tab.text.contains('漫画') ? true : false,
                      onPageTop: _onTopOfPicpage,
                      onPageStart: _onStartOfPicpage,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return (Container());
    }
  }

  Widget _subscribeButton() {
    bool currentFollowedState = isFollowed;
    String buttonText = currentFollowedState ? texts.followed : texts.follow;

    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      color: Colors.blueAccent[200],
      onPressed: () async {
        String url = '/users/followed';
        Map<String, String> body = {
          'artistId': widget.artistId,
          'userId': prefs.getInt('id').toString(),
          'username': prefs.getString('name'),
        };
        // CancelFunc cancelLoading;

        try {
          // cancelLoading = BotToast.showLoading();
          if (currentFollowedState) {
            await dioPixivic.delete(
              url,
              data: body,
            );
          } else {
            await dioPixivic.post(
              url,
              data: body,
            );
          }
          // cancelLoading();
          setState(() {
            isFollowed = !isFollowed;
          });
          if (widget.followedRefresh != null)
            widget.followedRefresh(isFollowed);
        } catch (e) {
          // cancelLoading();
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

  _initPappbar() {
    String tempTitle = widget.artistName;
    tempTitle.length > 20
        ? tempTitle = tempTitle.substring(0, 20) + '...'
        : tempTitle = tempTitle;
    pappBar = PappBar(title: tempTitle);
  }
}
