import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/texts.dart';
import '../data/common.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requests/requests.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:lottie/lottie.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();

  UserListPage({this.mode = 'bookmark'});
  UserListPage.bookmark({this.mode = 'bookmark'});

  final String mode;
}

class _UserListPageState extends State<UserListPage> {
  TextUserListPage texts;
  ScrollController scrollController;
  int currentPage;
  List jsonList;
  int totalNum;
  bool loadMoreAble;
  bool haveConnected;

  @override
  void initState() {
    texts = TextUserListPage();
    currentPage = 1;
    haveConnected = false;
    loadMoreAble = true;
    scrollController = ScrollController()..addListener(_doWhileScrolling);

    _getJsonList().then((value) {
      haveConnected = true;
      if (value != null) {
        setState(() {
          totalNum = value.length;
          jsonList = value;
        });
      } else {
        setState(() {
          jsonList = value;
        });
      }
    }).catchError((e) {
      print('TextUserListPage init error: $e');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!haveConnected)
      return Lottie.asset('image/loading-box.json');
    else
      return Scaffold(
        body: jsonList != null
            ? ListView(
                children: <Widget>[
                  title(),
                  ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      itemCount: totalNum,
                      itemBuilder: (BuildContext context, int index) {
                        return UserCell();
                      }),
                ],
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
              ),
      );
  }

  Widget title() {
    if (widget.mode == 'bookmark') {
      return Container(
        alignment: Alignment.centerLeft,
        child: Text(texts.theseUserBookmark),
      );
    } else {
      return Container();
    }
  }
  
  Widget UserCell() {

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

  _doWhileScrolling() {}
}
