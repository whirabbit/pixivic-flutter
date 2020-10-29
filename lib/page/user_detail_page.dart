import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import 'package:pixivic/data/common.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/page//artist_list_page.dart';
import 'package:pixivic/page/pic_page.dart';

class UserDetailPage extends StatefulWidget {
  @override
  _UserDetailPageState createState() => _UserDetailPageState();

  UserDetailPage(this.userId, this.name);

  final int userId;
  final String name;
}

class _UserDetailPageState extends State<UserDetailPage> {
  ScrollController scrollController;
  List<Tab> tabs;

  @override
  void initState() {
    scrollController = ScrollController();
    tabs = <Tab>[
      Tab(
        text: '插画',
      ),
      Tab(
        text: '漫画',
      ),
    ];
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PappBar(
          title: widget.name,
        ),
        body: Container(
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
                      CircleAvatar(
                        backgroundImage: AdvancedNetworkImage(
                          'https://static.pixivic.net/avatar/299x299/${widget.userId.toString()}.jpg',
                          header: {'Referer': 'https://app-api.pixiv.net'},
                          useDiskCache: true,
                          cacheRule: CacheRule(
                              maxAge:
                                  Duration(days: prefs.getInt('previewRule'))),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(20),
                      ),
                      Text(
                        widget.name,
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(25),
                      ),
                      Material(
                        color: Colors.white,
                        child: InkWell(
                          child: Text(
                            'Ta的关注',
                            style: TextStyle(color: Colors.blue[300]),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Scaffold(
                                      appBar:
                                          PappBar(title: '${widget.name}的关注'),
                                      body: ArtistListPage.userFollow(
                                          userId: widget.userId),
                                    )));
                          },
                        ),
                      )
                    ],
                  )),
              // 相关图片
              Container(
                height: ScreenUtil().setHeight(521),
                width: ScreenUtil().setWidth(324),
                child: _tabViewer(),
              )
            ],
          ),
        ));
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
                    return PicPage.userdetail(
//                      funOne: true,
                      userId: widget.userId.toString(),
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
}
