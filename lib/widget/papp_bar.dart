import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PappBar extends StatefulWidget implements PreferredSizeWidget {
  //删去
  final String title;
  final String mode;
  final String searchKeywordsIn;
  final ValueChanged<String> searchFucntion;
  final ValueChanged<String> homeModeOptionsFucntion;
  final Key key;

  PappBar({
    this.title,
    this.mode = 'default',
    this.searchKeywordsIn,
    this.searchFucntion,
    this.homeModeOptionsFucntion,
    this.key,
  }) : super();

  PappBar.search(
      {this.title,
      this.mode = 'search',
      @required this.searchKeywordsIn,
      @required this.searchFucntion,
      this.homeModeOptionsFucntion,
      this.key})
      : super();

  PappBar.home(
      {this.title,
      this.mode = 'home',
      this.searchKeywordsIn,
      this.searchFucntion,
      @required this.homeModeOptionsFucntion,
      this.key})
      : super();

  @override
  PappBarState createState() => PappBarState();

  @override
  Size get preferredSize => Size.fromHeight(ScreenUtil().setHeight(35));
}

class PappBarState extends State<PappBar> {
  double contentHeight;
  String title = '日排行';
  String lastHomeTitle;
  String mode;
  TextEditingController searchController;

  @override
  void initState() {
    if(widget.title != null)
      title = widget.title;
    lastHomeTitle = title;
    mode = widget.mode;
    searchController = TextEditingController(
        text: widget.searchKeywordsIn != null ? widget.searchKeywordsIn : null);
    contentHeight = ScreenUtil().setHeight(35);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: SafeArea(
        top: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 13,
                  offset: Offset(5, 5),
                  color: Color(0x73E5E5E5)),
            ],
          ),
          height: contentHeight,
          child: chooseWidget(),
        ),
      ),
    );
  }

  Widget chooseWidget() {
    if (mode == 'home') {
      return homeWidgets();
    } else if (mode == 'default') {
      return defaultWidgets();
    } else if (mode == 'search') {
      return searchWidgets();
    } else {
      return Container();
    }
  }

  Widget homeWidgets() {
    return Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(18), right: ScreenUtil().setWidth(18)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  // Navigator.of(context).pop();
                  widget.homeModeOptionsFucntion('search');
                },
                child: Container(
                  height: contentHeight,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(right: 8), //为点击时的效果而设置，无实际意义
                  child: FaIcon(
                    FontAwesomeIcons.search,
                    color: Color(0xFF515151),
                    size: ScreenUtil().setWidth(15),
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return homeBottomSheet();
                      });
                },
                child: Container(
                  height: contentHeight,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          // color: Color(0xFF515151),
                          color: Colors.orange[400],
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  // Navigator.of(context).pop();
                  widget.homeModeOptionsFucntion('new_date');
                },
                child: Container(
                  height: contentHeight,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 8),
                  child: FaIcon(
                    FontAwesomeIcons.calendarAlt,
                    color: Color(0xFF515151),
                    size: ScreenUtil().setWidth(15),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget defaultWidgets() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(18), right: ScreenUtil().setWidth(18)),
        child: Text(title,
            style: TextStyle(
                fontSize: 14,
                color: Color(0xFF515151),
                fontWeight: FontWeight.w700)));
  }

  Widget searchWidgets() {
    return Container(
        padding: EdgeInsets.only(left: ScreenUtil().setWidth(18)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: contentHeight,
              alignment: Alignment.center,
              child: FaIcon(
                FontAwesomeIcons.search,
                color: Color(0xFF515151),
                size: ScreenUtil().setWidth(15),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(265),
              height: ScreenUtil().setHeight(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFFF4F3F3F3),
              ),
              margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(13),
                right: ScreenUtil().setWidth(12),
              ),
              child: TextField(
                controller: searchController,
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  widget.searchFucntion(searchController.text);
                },
                decoration: InputDecoration(  
                    border: InputBorder.none,
                    hintText: '要搜点什么呢',
                    contentPadding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(8), 
                        bottom: ScreenUtil().setHeight(8))),
              ),
            ),
          ],
        ));
  }

  Widget homeBottomSheet() {
    return Container(
      height: ScreenUtil().setHeight(110),
      width: ScreenUtil().setWidth(324),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(30),
              width: ScreenUtil().setWidth(324),
              child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  labelColor: Colors.orange[300],
                  unselectedLabelColor: Colors.blueGrey,
                  tabs: [
                    Tab(
                      child: Text(
                        '综合',
                      ),
                    ),
                    Tab(
                      child: Text(
                        '漫画',
                      ),
                    )
                  ]),
            ),
            Expanded(
              child: TabBarView(children: <Widget>[
                selectorContainer('illust'),
                selectorContainer('manga')
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget selectorContainer(String type) {
    if (type == 'illust') {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                optionButton('日排行', 'day'),
                optionButton('周排行', 'week'),
                optionButton('月排行', 'month'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                optionButton('男性日排行', 'male'),
                optionButton('女性日排行', 'female'),
              ],
            )
          ],
        ),
      );
    } else if (type == 'manga') {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                optionButton('日排行', 'day_manga'),
                optionButton('周排行', 'week_manga'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                optionButton('月排行', 'month_manga'),
                optionButton('新秀周排行', 'week_rookie_manga'),
              ],
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget optionButton(String label, String parameter) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(3), right: ScreenUtil().setWidth(3)),
      child: ButtonTheme(
        height: ScreenUtil().setHeight(20),
        minWidth: ScreenUtil().setWidth(2),
        buttonColor: Colors.grey[100],
        splashColor: Colors.grey[100],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
        child: OutlineButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.homeModeOptionsFucntion(parameter);
            setState(() {
              title = label;
              lastHomeTitle = title;
            });
          },
          child: Text(label),
        ),
      ),
    );
  }

  void changePappbarMode(int index) {
    setState(() {
      switch (index) {
        case 0:
          mode = 'home';
          title = lastHomeTitle;
          break;
        case 1:
          mode = 'default';
          title = '功能中心';
          break;
        case 2:
          mode = 'default';
          title = '画师更新';
          break;
        case 3:
          mode = 'default';
          title = '用户中心';
          break;
        default:
          mode = 'home';
          title = '日排行';
      }
    });
  }

  void changeSearchKeywords(String keywords) {
    setState(() {
      searchController.text = keywords;
    });
  }
}
