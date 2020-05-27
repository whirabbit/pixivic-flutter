import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requests/requests.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:lottie/lottie.dart';

import '../data/common.dart';
import '../data/texts.dart';
import '../page/artist_page.dart';
import '../page/pic_detail_page.dart';

class ArtistListPage extends StatefulWidget {
  @override
  _ArtistListPageState createState() => _ArtistListPageState();

  ArtistListPage(this.mode, {this.searchKeyWords});
  ArtistListPage.search(this.searchKeyWords, {this.mode = 'search'});
  ArtistListPage.follow({this.searchKeyWords, this.mode = 'follow'});

  final String mode;
  final String searchKeyWords;
}

class _ArtistListPageState extends State<ArtistListPage> {
  TextZhFollowPage text = TextZhFollowPage();
  ScrollController scrollController;
  int currentPage;
  List jsonList;
  int followTotalNum;
  bool loadMoreAble;
  bool haveConnected;

  @override
  void initState() {
    currentPage = 1;
    haveConnected = false;
    loadMoreAble = true;
    scrollController = ScrollController()..addListener(_doWhileScrolling);
    _getJsonList().then((value) {
      haveConnected = true;
      if (value != null) {
        setState(() {
          followTotalNum = value.length;
          jsonList = value;
        });
      } else {
        setState(() {
          jsonList = value;
        });
      }
    }).catchError((e) {
      print('ArtistListPage init error: $e');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!haveConnected)
      return Lottie.asset('image/loading-box.json');
    else
      return jsonList != null
          ? Container(
              color: Colors.white,
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: followTotalNum,
                  itemBuilder: (BuildContext context, int index) {
                    return artistCell(jsonList[index], jsonList[index]);
                  }),
            )
          : Container(
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
  }

  Widget titleCell() {
    return Container(
      color: Colors.white,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(ScreenUtil().setHeight(5)),
      child: Text(
        text.title,
        style: TextStyle(
            fontSize: ScreenUtil().setWidth(14),
            color: Colors.black,
            decoration: TextDecoration.none),
      ),
    );
  }

  Widget artistCell(Map cellData, Map picData) {
    return Container(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
      child: Column(
        children: <Widget>[
          picsCell(picData),
          Material(
            child: InkWell(
              onTap: () {
                _routeToArtistPage(cellData);
              },
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(cellData['avatar'],
                              headers: {
                                'Referer': 'https://app-api.pixiv.net'
                              }),
                        ),
                      ),
                      Text(cellData['name'],
                          style: TextStyle(
                              fontSize: ScreenUtil().setWidth(10),
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                    ],
                  ),
                  Positioned(
                      top: ScreenUtil().setWidth(10),
                      right: ScreenUtil().setWidth(15),
                      child: prefs.getString('auth') != ''
                          ? Container(
                              alignment: Alignment.centerRight,
                              child: _subscribeButton(cellData),
                            )
                          : Container()),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget picsCell(Map picData) {
    int itemNum = picData['recentlyIllustrations'].length;
    List<int> allIndex = List<int>.generate(itemNum, (int index) => index);
    return Row(
      children: allIndex.map((int item) {
        return Container(
          width: ScreenUtil().setWidth(108),
          height: ScreenUtil().setWidth(108),
          color: Colors.grey[200],
          child: picData['recentlyIllustrations'][item]['sanityLevel'] <=
                  prefs.getInt('sanityLevel')
              ? GestureDetector(
                  onTap: () {
                    _routeToPicDetailPage(
                        picData['recentlyIllustrations'][item]);
                  },
                  child: Image.network(
                    picData['recentlyIllustrations'][item]['imageUrls'][0]
                        ['squareMedium'],
                    headers: {'Referer': 'https://app-api.pixiv.net'},
                    width: ScreenUtil().setWidth(108),
                    height: ScreenUtil().setWidth(108),
                  ),
                )
              : Stack(
                  children: <Widget>[
                    Image.network(
                      picData['recentlyIllustrations'][item]['imageUrls'][0]
                          ['squareMedium'],
                      headers: {'Referer': 'https://app-api.pixiv.net'},
                      width: ScreenUtil().setWidth(108),
                      height: ScreenUtil().setWidth(108),
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Opacity(
                            opacity: 0.5, //透明度
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200), //盒子装饰器，模糊的颜色
                            )),
                      ),
                    ),
                  ],
                ),
        );
      }).toList(),
    );
  }

  Widget _subscribeButton(Map data) {
    bool currentFollowedState =
        data['isFollowed'] != null ? data['isFollowed'] : false;
    String buttonText = currentFollowedState ? text.followed : text.follow;

    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      color: Colors.blueAccent[200],
      onPressed: () async {
        String url = 'https://api.pixivic.com/users/followed';
        Map<String, String> body = {
          'artistId': data['id'].toString(),
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
            data['isFollowed'] = !data['isFollowed'];
          });
        } catch (e) {
          print(e);
          // print(homePicList[widget.index]['artistPreView']['isFollowed']);
          BotToast.showSimpleNotification(title: text.followError);
        }
      },
      child: Text(
        buttonText,
        style:
            TextStyle(fontSize: ScreenUtil().setWidth(10), color: Colors.white),
      ),
    );
  }

  _getJsonList() async {
    String url;
    List jsonList;
    var requests;

    if (widget.mode == 'search') {
      url =
          'https://api.pixivic.com/artists?page=$currentPage&artistName=${widget.searchKeyWords}&pageSize=30';
    } else if (widget.mode == 'follow') {
      url =
          'https://api.pixivic.com/users/${prefs.getInt('id').toString()}/followedWithRecentlyIllusts?page=$currentPage&pageSize=30';
    }

    try {
      if (prefs.getString('auth') == '') {
        requests = await Requests.get(url);
      } else {
        Map<String, String> headers = {
          'authorization': prefs.getString('auth')
        };
        requests = await Requests.get(url, headers: headers);
      }
      jsonList = jsonDecode(requests.content())['data'];
      // print(jsonList);
      if (jsonList == null)
        loadMoreAble = false;
      else
        loadMoreAble = true;
      return (jsonList);
    } catch (error) {
      print('=========getJsonList==========');
      print(error);
      print('==============================');
      if (error.toString().contains('SocketException'))
        BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
    }
  }

  _routeToArtistPage(Map data) {
    bool isFollowed;
    if (data['isFollowed'] == null) {
      isFollowed = false;
    } else {
      isFollowed = data['isFollowed'];
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return ArtistPage(
          data['avatar'],
          data['name'],
          data['id'].toString(),
          isFollowed: isFollowed,
          followedRefresh: (bool result) {
            setState(() {
              data['isFollowed'] = result;
            });
          },
        );
      },
    ));
  }

  _routeToPicDetailPage(Map picData) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PicDetailPage(picData)));
  }

  _doWhileScrolling() {
    FocusScope.of(context).unfocus();
    if ((scrollController.position.extentAfter < 890) &&
        (currentPage < 30) &&
        loadMoreAble) {
      loadMoreAble = false;
      currentPage++;
      print('current page is $currentPage');
      _getJsonList().then((value) {
        if (value != null) {
          jsonList = jsonList + value;
          followTotalNum = followTotalNum + value.length;
          setState(() {
            loadMoreAble = true;
          });
        }
      }).catchError((error) {
        print('=========getJsonList==========');
        print(error);
        print('==============================');
        if (error.toString().contains('SocketException'))
          BotToast.showSimpleNotification(title: '网络异常，请检查网络(´·_·`)');
        setState(() {
          loadMoreAble = true;
        });
      });
    }
  }
}
