import 'package:flutter/material.dart';

// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixivic/provider/favorite_animation.dart';
import 'package:pixivic/provider/get_page.dart';
import 'package:pixivic/provider/page_switch.dart';
import 'package:requests/requests.dart';
import 'package:random_color/random_color.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:provider/provider.dart';

import 'pic_detail_page.dart';
import '../data/common.dart';

// 可以作为页面中单个组件或者单独页面使用的pic瀑布流组件,因可以作为页面，故不归为widget
class PicPage extends StatefulWidget {
  @override
  _PicPageState createState() => _PicPageState();

  PicPage({
    this.picDate,
    this.picMode,
    this.relatedId = 0,
    this.jsonMode = 'home',
    this.searchKeywords,
    this.isManga,
    this.artistId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
  });

  PicPage.home({
    @required this.picDate,
    @required this.picMode,
    this.relatedId,
    this.jsonMode = 'home',
    this.searchKeywords,
    this.isManga,
    this.artistId,
    this.userId,
    this.spotlightId,
    this.collectionId,
//    @required this.onPageScrolling,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.related({
    @required this.relatedId,
    this.picDate,
    this.picMode,
    this.jsonMode = 'related',
    this.searchKeywords,
    this.isManga,
    this.artistId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    @required this.onPageTop,
    @required this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.search({
    @required this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'search',
    this.relatedId,
    this.userId,
    this.isManga = false,
    this.artistId,
    this.collectionId,
    this.spotlightId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.artist({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'artist',
    this.relatedId,
    this.userId,
    this.isManga = false,
    @required this.artistId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    @required this.onPageTop,
    @required this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.followed({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'followed',
    this.relatedId,
    @required this.userId,
    this.isManga = false,
    this.artistId,
    this.spotlightId,
    this.collectionId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.bookmark({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'bookmark',
    this.relatedId,
    @required this.userId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.spotlightId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.spotlight({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'spotlight',
    this.relatedId,
    this.userId,
    this.collectionId,
    @required this.spotlightId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.history({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'history',
    this.relatedId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.oldHistory({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'oldhistory',
    this.relatedId,
    this.userId,
    this.spotlightId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.userdetail({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'userdetail',
    this.relatedId,
    @required this.userId,
    this.spotlightId,
    this.collectionId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  PicPage.collection({
    this.searchKeywords,
    this.picDate,
    this.picMode,
    this.jsonMode = 'collection',
    this.relatedId,
    this.userId,
    @required this.collectionId,
    this.spotlightId,
    this.isManga = false,
    this.artistId,
    this.onPageScrolling,
    this.onPageTop,
    this.onPageStart,
    this.isScrollable = true,
//    @required this.funOne,
  });

  final String picDate;
  final String picMode;
  final num relatedId;
  final String artistId;
  final String spotlightId;
  final String userId;
  final String collectionId;
  final String searchKeywords;
  final bool isManga;
  final bool isScrollable;

  // jsonMode could be set to 'home, related, Spotlight, tag, artist, search...'
  final String jsonMode;

  // hide naviagtor bar when page is scrolling
  final ValueChanged<bool> onPageScrolling;
  final VoidCallback onPageTop;
  final VoidCallback onPageStart;
}

class _PicPageState extends State<PicPage> with AutomaticKeepAliveClientMixin {
  // pageProvider.picList - 图片的JSON文件列表
  // picTotalNum - pageProvider.picList 中项目的总数（非图片总数，因为单个项目有可能有多个图片）
  // 针对最常访问的 Home 页面，临时变量记录于 common.dart
//  List pageProvider.picList = [];
  int picTotalNum;
  int currentPage = 1;
  RandomColor _randomColor = RandomColor();
  bool hasConnected = false;
  bool loadMoreAble = true;
  bool isScrolling = false;
  bool firstInit;
  ScrollController scrollController;
  String previewQuality = prefs.getString('previewQuality');
  PageSwitchProvider indexProvider;
  GetPageProvider getPageProvider;

  @override
  void initState() {
    firstInit = true;
    scrollController = ScrollController(
        initialScrollOffset:
            widget.jsonMode == 'home' ? homeScrollerPosition : 0.0)
      ..addListener(_doWhileScrolling);
//    loadMoreAble = ifLoadMoreAble();
    super.initState();
  }

//  @override
//  void didUpdateWidget(PicPage oldWidget) {
//    print('picPage didUpdateWidget: mode is ${widget.jsonMode}');
//    // 当为 home 模式且切换了参数，则同时更新暂存的相关数据
//    if (widget.jsonMode == 'home' &&
//            (oldWidget.picDate != widget.picDate ||
//                oldWidget.picMode != widget.picMode) ||
//        widget.jsonMode == 'search') {
//      //切换model
//      firstInit = true;
//      pageProvider.picList = [];
//      scrollController.animateTo(
//        0.0,
//        duration: const Duration(milliseconds: 500),
//        curve: Curves.easeOut,
//      );
//    }
//
//    super.didUpdateWidget(oldWidget);
//  }

  @override
  void dispose() {
    print('PicPage Disposed');
    // scrollController.removeListener(_doWhileScrolling);
    // scrollController.dispose();
//    if (widget.jsonMode == 'home' && pageProvider.picList != null) {
//      homepageProvider.picList = pageProvider.picList;
//      homeCurrentPage = currentPage;
//    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    super.build(context);
    return ChangeNotifierProvider<GetPageProvider>.value(
      value: GetPageProvider(),
      child: Selector<GetPageProvider, GetPageProvider>(
        shouldRebuild: (pre, next) => true,
        selector: (context, provider) => provider,
        builder: (context, GetPageProvider pageProvider, _) {
          getPageProvider = pageProvider;
          switchModel(pageProvider);
          if (pageProvider.jsonList == null) {
            pageProvider.getJsonList().then((value) {
              if (value.length==0) {
                hasConnected = true;
              }
            });
            pageProvider.picList = [];
            pageProvider.jsonList = [];
          }
          pageProvider.picList = pageProvider.picList + pageProvider.jsonList;
//          firstInit = false;
          if (pageProvider.picList.length == 0 && !hasConnected) {
            return Container(
                height: ScreenUtil().setHeight(576),
                width: ScreenUtil().setWidth(324),
                alignment: Alignment.center,
                color: Colors.white,
                child: Center(
                  child: Lottie.asset('image/loading-box.json'),
                ));
          } else if (pageProvider.picList.length == 0 && hasConnected) {
            return Container(
              height: ScreenUtil().setHeight(576),
              width: ScreenUtil().setWidth(324),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Lottie.asset('image/empty-box.json',
                      repeat: false, height: ScreenUtil().setHeight(100)),
                  Text(
                    '这里什么都没有呢',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: ScreenUtil().setHeight(10),
                        decoration: TextDecoration.none),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(250),
                  )
                ],
              ),
            );
          } else {
//
            return Container(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(5),
                    right: ScreenUtil().setWidth(5)),
                color: Colors.grey[50],
                child: StaggeredGridView.countBuilder(
                  controller: scrollController,
                  physics: widget.isScrollable
                      ? ClampingScrollPhysics()
                      : NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  itemCount: pageProvider.picList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Selector<GetPageProvider, Map>(
                      selector: (context, provider) => provider.picList[index],
                      builder: (context, picItem, child) {
                        return imageCell(picItem,index);
                      },
                    );
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 0.0,
                  crossAxisSpacing: 0.0,
                ));
          }
        },
      ),
//    create: (_)=>,
    );
  }

  //根据传入的jsonModel选择provider的方法来获取数据
  void switchModel(GetPageProvider provider) {
    switch (widget.jsonMode) {
      case 'home':
        provider.homePage(picDate: widget.picDate, picMode: widget.picMode);
        break;
      case 'related':
        provider.relatedPage(
            relatedId: widget.relatedId,
            onTopOfPicpage: widget.onPageTop,
            onStartOfPicpage: widget.onPageStart);
        break;
      case 'search':
        provider.searchPage(
            searchKeywords: widget.searchKeywords, searchManga: widget.isManga);
        break;
      case 'artist':
        provider.artistPage(
            artistId: widget.artistId,
            isManga: widget.isManga,
            onTopOfPicpage: widget.onPageTop,
            onStartOfPicpage: widget.onPageStart);
        break;
      case 'followed':
        provider.followedPage(userId: widget.userId, isManga: widget.isManga);
        break;
      case 'bookmark':
        provider.bookmarkPage(userId: widget.userId, isManga: widget.isManga);
        break;
      case 'spotlight':
        provider.spotlightPage(spotlightId: widget.spotlightId);
        break;
      case 'history':
        provider.historyPage();
        break;
      case 'oldhistory':
        provider.oldHistoryPage();
        break;
      case 'userdetial':
        provider.userdetailPage(
            userId: widget.userId,
            isManga: widget.isManga,
            onTopOfPicpage: widget.onPageTop,
            onStartOfPicpage: widget.onPageStart);
        break;
      case 'collection':
        provider.collectionPage(collectionId: widget.collectionId);
        break;
    }
  }

  List _picMainParameter(Map picItem) {
    // 预览图片的地址、数目、以及长宽比
    // String url = pageProvider.picList[index]['imageUrls'][0]['squareMedium'];
    String url = picItem['imageUrls'][0][previewQuality]; //medium large
    int number = picItem['pageCount'];
    double width = picItem['width'].toDouble();
    double height = picItem['height'].toDouble();
    return [url, number, width, height];
  }

  _doWhileScrolling() {
//    print("滑出ViewPort顶部的长度"+scrollController.position.extentBefore.toString());
//    print("ViewPort内部长度"+scrollController.position.extentInside.toString());
//      print("测量"+scrollController.position.extentAfter.toString());
//    FocusScope.of(context).unfocus();
    // 如果为主页面 picPage，则记录滑动位置、判断滑动
    if (widget.jsonMode == 'home') {
      homeScrollerPosition = scrollController
          .position.extentBefore; // 保持记录scrollposition，原因为dispose时无法记录
      indexProvider = Provider.of<PageSwitchProvider>(context, listen: false);
      // 判断是否在滑动，以便隐藏底部控件
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!indexProvider.judgeScrolling) {
          indexProvider.changeScrolling(true);
//          isScrolling = true;
//          widget.onPageScrolling(isScrolling);
        }
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        //显示
        if (indexProvider.judgeScrolling) {
          indexProvider.changeScrolling(false);
//          isScrolling = false;
//          widget.onPageScrolling(isScrolling);
        }
      }
    }

//    if (widget.jsonMode == 'related' ||
//        widget.jsonMode == 'artist' ||
//        widget.jsonMode == 'userdetail') {
//      if (scrollController.position.extentBefore == 0 &&
//          scrollController.position.userScrollDirection ==
//              ScrollDirection.forward) {
//        widget.onPageTop();
//        print('on page top');
//      }
//      if (scrollController.position.extentBefore > 150 &&
//          scrollController.position.extentBefore < 200 &&
//          scrollController.position.userScrollDirection ==
//              ScrollDirection.reverse) {
//        widget.onPageStart();
//        print('on page start');
//      }
//    }

    // Auto Load
    if ((scrollController.position.extentAfter < 1200) &&
        (currentPage < 30) &&
        loadMoreAble) {
      print("Picpage: Load Data");
      loadMoreAble = false;
      currentPage++;
      print('current page is $currentPage');
      try {
        getPageProvider
            .getJsonList(currentPage: currentPage, loadMoreAble: loadMoreAble)
            .then((value) {
          if (value != null) {
            loadMoreAble = true;
          }
        });
      } catch (err) {
        print('=========getJsonList==========');
        print(err);
        print('==============================');
        if (err.toString().contains('SocketException'))
          BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
        loadMoreAble = true;
      }
    }
  }

  ifLoadMoreAble() {
    switch (widget.jsonMode) {
      case 'followed':
        return false;
        break;
      case 'spotlight':
        return false;
        break;
      default:
        return true;
    }
  }

  Widget imageCell(Map picItem,int index) {
    final Color color = _randomColor.randomColor();
    Map picMapData = Map.from(picItem);
    if (picMapData['xrestict'] == 1 ||
        picMapData['sanityLevel'] > prefs.getInt('sanityLevel'))
      return Container();
    else
      return Container(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(5),
          right: ScreenUtil().setWidth(5),
          top: ScreenUtil().setWidth(10),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: () async {
                    // 对广告图片做区分判断
                    if (picMapData['type'] == 'ad_image') {
                      if (await canLaunch(picMapData['link'])) {
                        await launch(picMapData['link']);
                      } else {
                        BotToast.showSimpleNotification(title: '唤起网页失败');
                        throw 'Could not launch ${picMapData['link']}';
                      }
                    }
                    else
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PicDetailPage(picMapData,
                                  index: index,
                                  bookmarkRefresh: _bookmarkRefresh)));
                  },
                  child: Container(
                    // 限定constraints用于占用位置,经调试后以0.5为基准可以保证加载图片后不产生位移
                    constraints: BoxConstraints(
                        // minHeight: MediaQuery.of(context).size.width *
                        //     0.5 /
                        //     _picMainParameter(index)[2] *
                        //     _picMainParameter(index)[3],
                        // minWidth: MediaQuery.of(context).size.width * 0.41,
                        minHeight: ScreenUtil().setWidth(148) /
                            _picMainParameter(picItem)[2] *
                            _picMainParameter(picItem)[3],
                        minWidth: ScreenUtil().setWidth(148)),
                    child: Hero(
                      tag: 'imageHero' + _picMainParameter(picItem)[0],
                      child: Image(
                        image: AdvancedNetworkImage(
                          _picMainParameter(picItem)[0],
                          header: {'Referer': 'https://app-api.pixiv.net'},
                          useDiskCache: true,
                          cacheRule: CacheRule(
                              maxAge:
                                  Duration(days: prefs.getInt('previewRule'))),
                        ),
                        fit: BoxFit.fill,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return Container(
                            child: AnimatedOpacity(
                              child: frame == null
                                  ? Container(color: color)
                                  : child,
                              opacity: frame == null ? 0.3 : 1,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              child: numberViewer(_picMainParameter(picItem)[1]),
              right: ScreenUtil().setWidth(10),
              top: ScreenUtil().setHeight(5),
            ),
            prefs.getString('auth') != '' && picMapData['type'] != 'ad_image'
                ? Positioned(
                    bottom: ScreenUtil().setHeight(5),
                    right: ScreenUtil().setWidth(5),
                    child: bookmarkHeart(picItem,index))
                : Container(),
          ],
        ),
      );
  }

  Widget numberViewer(num numberOfPic) {
    return (numberOfPic != 1)
        ? Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
            decoration: BoxDecoration(
                color: Colors.black38, borderRadius: BorderRadius.circular(3)),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.content_copy,
                  color: Colors.white,
                  size: ScreenUtil().setWidth(10),
                ),
                Text(
                  '$numberOfPic',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setHeight(10),
                      decoration: TextDecoration.none),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget bookmarkHeart(Map picItem,int index) {
    bool isLikedLocalState = picItem['isLiked'];
    var color = isLikedLocalState ? Colors.redAccent : Colors.grey[300];
    String picId = picItem['id'].toString();

    return ChangeNotifierProvider<FavProvider>(
      create: (_) => FavProvider(),
      child: Container(
//      duration: Duration(milliseconds: 500),
//      curve: Curves.fastLinearToSlowEaseIn,
          alignment: Alignment.center,
          // color: Colors.white,
          height: ScreenUtil().setWidth(33),
          width: ScreenUtil().setWidth(33),
//            height: isLikedLocalState
//                ? ScreenUtil().setWidth(33)
//                : ScreenUtil().setWidth(27),
//            width: isLikedLocalState
//                ? ScreenUtil().setWidth(33)
//                : ScreenUtil().setWidth(27),
          child: Consumer<FavProvider>(
            builder: (context, FavProvider favProvider, _) {
              return IconButton(
                color: color,
                padding: EdgeInsets.all(0),
                iconSize: ScreenUtil().setHeight(favProvider.iconSize),
                icon: Icon(Icons.favorite),
                onPressed: () async {
                  //点击动画
                  favProvider.clickFunc();
                  String url = 'https://api.pixivic.com/users/bookmarked';
                  Map<String, String> body = {
                    'userId': prefs.getInt('id').toString(),
                    'illustId': picId.toString(),
                    'username': prefs.getString('name')
                  };
                  Map<String, String> headers = {
                    'authorization': prefs.getString('auth')
                  };
                  try {
                    if (isLikedLocalState) {
                      await Requests.delete(url,
                          body: body,
                          headers: headers,
                          bodyEncoding: RequestBodyEncoding.JSON);
                    } else {
                      await Requests.post(url,
                          body: body,
                          headers: headers,
                          bodyEncoding: RequestBodyEncoding.JSON);
                    }
                    Future.delayed(Duration(milliseconds: 400), () {
//                      setState(() {
                      getPageProvider.markFun(index);

//                      });
                    });
//                    setState(() {
//                      pageProvider.picList[index]['isLiked'] = !pageProvider.picList[index]['isLiked'];
//                    });
                  } catch (e) {
                    print(e);
                  }
                },
              );
            },
          )

//        GestureDetector(
//            onTap: () async {
//              //点击动画
//              favProvider.clickFunc();
//              String url = 'https://api.pixivic.com/users/bookmarked';
//              Map<String, String> body = {
//                'userId': prefs.getInt('id').toString(),
//                'illustId': picId.toString(),
//                'username': prefs.getString('name')
//              };
//              Map<String, String> headers = {
//                'authorization': prefs.getString('auth')
//              };
//              try {
//                if (isLikedLocalState) {
//                  await Requests.delete(url,
//                      body: body,
//                      headers: headers,
//                      bodyEncoding: RequestBodyEncoding.JSON);
//                } else {
//                  await Requests.post(url,
//                      body: body,
//                      headers: headers,
//                      bodyEncoding: RequestBodyEncoding.JSON);
//                }
//                Future.delayed(Duration(milliseconds: 400), () {
////                      setState(() {
//                  picItem['isLiked'] = !picItem['isLiked'];
//
////                      });
//                }
//                );
////                    setState(() {
////                      pageProvider.picList[index]['isLiked'] = !pageProvider.picList[index]['isLiked'];
////                    });
//              } catch (e) {
//                print(e);
//              }
//            },
//            child: Icon(
//              Icons.favorite,
//              color: color,
//              size: ScreenUtil().setHeight(favProvider.iconSize),
//            )
//
////              LayoutBuilder(builder: (context, constraint) {
//////                print(favProvider.iconSize);
////                return Icon(Icons.favorite,
////                    color: color,
////                    size: favProvider.iconSize,
//////                    size: constraint.biggest.height
////                );
////              }
////              ),
//        ),
          ),
    );
  }

  _bookmarkRefresh(int index, bool result) {
    setState(() {
      getPageProvider.picList[index]['isLiked'] = result;
    });
  }

//页面状态保持
  @override
  bool get wantKeepAlive => true;
}
