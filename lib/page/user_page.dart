import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:get/get.dart';

import 'package:pixivic/page/login_page.dart';
import 'package:pixivic/sidepage/bookmark_page.dart';
import 'package:pixivic/sidepage/history_page.dart';
import 'package:pixivic/sidepage/vip_page.dart';
import 'package:pixivic/page/artist_list_page.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/function/identity.dart';
import 'package:pixivic/controller/user_data_controller.dart';
import 'package:pixivic/sidepage/phone_page.dart';

class UserPage extends StatefulWidget {
  @override
  UserPageState createState() => UserPageState();

  UserPage(this.key);

  final Key key;
}

class UserPageState extends State<UserPage> {
  final text = TextZhUserPage();
  UserDataController userDataController = Get.put(UserDataController());

  @override
  void initState() {
    print('UserPage Created');
    print(widget.key);
    super.initState();
  }

  @override
  void dispose() {
    print('UserPage Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return Stack(
        children: <Widget>[
          // background image
          Positioned(
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Image.asset(
                'image/userpage_head.jpg',
                width: ScreenUtil().setWidth(324),
                height: ScreenUtil().setHeight(125),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          // user card
          Positioned(
            left: ScreenUtil().setWidth(37),
            right: ScreenUtil().setWidth(37),
            top: ScreenUtil().setHeight(58),
            child: _userCard(),
          ),
          Positioned(top: ScreenUtil().setHeight(180), child: _optionList()),
        ],
      );
    } else {
      return Container(
          child: LoginPage(
        widgetFrom: 'userPage',
      ));
    }
  }

  Widget _userCard() {
    return Container(
      width: ScreenUtil().setWidth(250),
      height: ScreenUtil().setHeight(115),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: ScreenUtil().setHeight(25),
            child: Container(
              width: ScreenUtil().setWidth(250),
              height: ScreenUtil().setHeight(90),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Positioned(
              left: ScreenUtil().setWidth(27),
              child: Obx(
                () => Hero(
                  tag: 'userAvater',
                  child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: ScreenUtil().setHeight(25),
                      // 更换为 AdvancedNI
                      backgroundImage: AdvancedNetworkImage(
                          userDataController.avatarLink.value,
                          header: {'referer': 'https://pixivic.com'})),
                ),
              )),
          Positioned(
            top: ScreenUtil().setHeight(33),
            left: ScreenUtil().setWidth(90),
            child: GestureDetector(
              onLongPressEnd: ((LongPressEndDetails longPressEndDetails) {
                print(longPressEndDetails.velocity.pixelsPerSecond.dx);
                if (longPressEndDetails.velocity.pixelsPerSecond.dx < 0 &&
                    Theme.of(context).platform == TargetPlatform.android) {
                  print(6);
                  prefs.setInt('sanityLevel', 6);
                } else if (longPressEndDetails.velocity.pixelsPerSecond.dx >
                        0 &&
                    Theme.of(context).platform == TargetPlatform.android) {
                  print(3);
                  prefs.setInt('sanityLevel', 3);
                }
              }),
              child: Obx(
                () => Text(
                  '${userDataController.name.value}',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 18.00),
                ),
              ),
            ),
          ),
          Positioned(
              top: ScreenUtil().setHeight(65),
              left: ScreenUtil().setWidth(67),
              child: _userDetailCell(text.info, 0)),
          Positioned(
              top: ScreenUtil().setHeight(65),
              left: ScreenUtil().setWidth(167),
              child: _userDetailCell(text.fans, 0)),
        ],
      ),
    );
  }

  Widget _userDetailCell(String label, int number) {
    return Column(
      children: <Widget>[
        Text(
          '$number',
          style: TextStyle(
            color: Colors.blueAccent[200],
            fontSize: 14,
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(5),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        )
      ],
    );
  }

  Widget _optionList() {
    return Column(
      children: <Widget>[
        _optionCell(
            FaIcon(
              FontAwesomeIcons.solidHeart,
              color: Colors.red,
            ),
            text.favorite,
            _routeToBookmarkPage),
        _optionCell(
            FaIcon(
              FontAwesomeIcons.podcast,
              color: Colors.blue,
            ),
            text.follow,
            _routeToFollowPage),
        _optionCell(
            FaIcon(
              FontAwesomeIcons.rocket,
              color: Colors.green,
            ),
            text.vipSpeed,
            _routeToVIPPage),
        _optionCell(
            FaIcon(
              FontAwesomeIcons.history,
              color: Colors.grey,
            ),
            text.history,
            _routeToHistoryPage),
        _optionCell(
            FaIcon(
              FontAwesomeIcons.phone,
              color: Colors.amber[500],
            ),
            text.phone,
            _routeToPhonePage),
        _optionCell(
            FaIcon(
              FontAwesomeIcons.signOutAlt,
              color: Colors.orange,
            ),
            text.logout, () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(text.logout),
                  content: Text(text.makerSureLogout),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("取消"),
                      onPressed: () => Navigator.of(context).pop(), //关闭对话框
                    ),
                    FlatButton(
                      child: Text("确定"),
                      onPressed: () {
                        logout(context);
                        Navigator.of(context).pop(true); //关闭对话框
                      },
                    ),
                  ],
                );
              });
        })
      ],
    );
  }

  Widget _optionCell(FaIcon icon, String text, VoidCallback onTap) {
    return Container(
      height: ScreenUtil().setHeight(40),
      width: ScreenUtil().setWidth(324),
      child: ListTile(
          onTap: () {
            onTap();
          },
          leading: icon,
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.grey,
          ),
          title: Text(text, style: TextStyle(color: Colors.grey[700]))),
    );
  }

  checkLoginState() {
    print('userpage check login state');
    setState(() {});
  }

  _routeToBookmarkPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => BookmarkPage()));
  }

  _routeToFollowPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ArtistListPage.follow()));
  }

  _routeToVIPPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => VIPPage()));
  }

  _routeToHistoryPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HistoryPage()));
  }

  _routeToPhonePage() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(child: PhonePage());
        });
  }
}
