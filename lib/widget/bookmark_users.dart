import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pixivic/page/user_list_page.dart';
import 'package:pixivic/function/dio_client.dart';

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
  List data;
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
                'https://static.pixivic.net/avatar/299x299/${data[index]['userId'].toString()}.jpg',
                headers: {'referer': 'https://pixivic.com'})),
      );
  }

  void changeVisible(bool state) {
    setState(() {
      visible = state;
    });
  }

  void getBookmarkData() async {
    String url = '/illusts/${widget.illustId}/bookmarkedUsers?page=1&pageSize=3';
    var response = await dioPixivic.get(url);
    if (response.runtimeType != bool) {
      data = response.data['data'];
    }

    if (data != null) {
      numOfData = data.length;
      changeVisible(true);
    } else {
      changeVisible(false);
    }
  }
}
