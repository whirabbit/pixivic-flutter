import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/page/user_list_page.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/common/do/bookmarked_user.dart';
import 'package:pixivic/biz/illust/service/illust_service.dart';
import 'package:pixivic/common/config/get_it_config.dart';

class BookmarkUsers extends StatefulWidget {
  @override
  BookmarkUsersState createState() => BookmarkUsersState();

  BookmarkUsers(this.illustId);

  // final VoidCallback onTap;
  // final Key key;
  final int illustId;
}

class BookmarkUsersState extends State<BookmarkUsers> {
  bool visible = false;
  List<BookmarkedUser> userOfCollectionIllustList;
  int numOfData;

  @override
  void initState() {
    getBookmarkData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Container();
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserListPage(illustId: widget.illustId)));
        },
        child: Container(
          alignment: Alignment.centerLeft,
          color: Colors.white,
          width: ScreenUtil().setWidth(60),
          height: ScreenUtil().setHeight(24),
          child: Stack(
            children: <Widget>[
              singleCircle(0),
              singleCircle(1),
              singleCircle(2)
            ],
          ),
        ),
      );
    }
  }

  Widget singleCircle(num index) {
    num rightDistance = index * ScreenUtil().setWidth(12);
    if (index >= numOfData)
      return Container();
    else
      return Positioned(
        right: rightDistance.toDouble(),
        child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: ScreenUtil().setHeight(12),
            backgroundImage: NetworkImage(
                'https://static.pixivic.net/avatar/299x299/${userOfCollectionIllustList[index].userId.toString()}.jpg',
                headers: {'referer': 'https://pixivic.com'})),
      );
  }

  void changeVisible(bool state) {
    setState(() {
      visible = state;
    });
  }

  void getBookmarkData() async {
    String url =
        '/illusts/${widget.illustId}/bookmarkedUsers?page=1&pageSize=3';

    try {
      userOfCollectionIllustList = await getIt<IllustService>()
          .queryUserOfCollectionIllustList(widget.illustId, 1, 3);
      // Response response = await dioPixivic.get(url);
      // data = response.data['data'];
      if (userOfCollectionIllustList != null) {
        numOfData = userOfCollectionIllustList.length;
        changeVisible(true);
      } else {
        changeVisible(false);
      }
    } catch (e) {}
  }
}
