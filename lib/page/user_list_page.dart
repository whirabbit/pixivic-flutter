import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import '../data/texts.dart';
import '../data/common.dart';
import '../widget/papp_bar.dart';
import './user_detail_page.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:requests/requests.dart';
import 'package:lottie/lottie.dart';
import 'package:bot_toast/bot_toast.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();

  UserListPage({this.mode = 'bookmark', this.illustId});
  UserListPage.bookmark(this.illustId, {this.mode = 'bookmark'});

  final String mode;
  final int illustId;
}

class _UserListPageState extends State<UserListPage> {
  TextZhUserListPage texts = TextZhUserListPage();
  ScrollController scrollController;
  int currentPage;
  List jsonList;
  int totalNum;
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
  void dispose() {
    scrollController.removeListener(_doWhileScrolling);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!haveConnected)
      return Scaffold(body: Lottie.asset('image/loading-box.json'));
    else
      return Scaffold(
        appBar: PappBar(
          title: '这些用户也关注了',
        ),
        body: jsonList != null
            ? ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                itemCount: totalNum,
                itemBuilder: (BuildContext context, int index) {
                  return userCell(jsonList[index]);
                })
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
        padding: EdgeInsets.all(ScreenUtil().setHeight(10)),
        alignment: Alignment.centerLeft,
        child: Text(texts.theseUserBookmark),
      );
    } else {
      return Container();
    }
  }

  Widget userCell(Map data) {
    // print(data);
    return ListTile(
      title: Text(
        data['username'],
        style: TextStyle(fontSize: 14),
      ),
      subtitle: Text(
          DateFormat("dd-MM-yyyy").format(DateTime.parse(data['createDate'])),
          style: TextStyle(fontSize: 12, color: Colors.grey)),
      leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: ScreenUtil().setHeight(15),
          backgroundImage: NetworkImage(
              'https://pic.cheerfun.dev/${data['userId'].toString()}.png',
              headers: {'referer': 'https://pixivic.com'})),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                UserDetailPage(data['userId'], data['username'])));
      },
    );
  }

  _getJsonList() async {
    String url;
    List jsonList;
    var requests;

    if (widget.mode == 'bookmark') {
      url =
          'https://api.pixivic.com/illusts/${widget.illustId}/bookmarkedUsers?page=$currentPage&pageSize=30';
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

  _doWhileScrolling() {
    if ((scrollController.position.extentAfter < 590) && loadMoreAble) {
      loadMoreAble = false;
      currentPage++;
      print('current page is $currentPage');
      _getJsonList().then((value) {
        if (value != null) {
          jsonList = jsonList + value;
          totalNum = totalNum + value.length;
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
