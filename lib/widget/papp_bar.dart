import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:requests/requests.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:pixivic/data/texts.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/page/artist_page.dart';
import 'package:pixivic/page/pic_detail_page.dart';
import 'package:pixivic/function/uploadImage.dart';
import 'package:pixivic/function/identity.dart';
import 'package:pixivic/provider/page_switch.dart';
import 'package:pixivic/provider/common_model.dart';
// import 'package:pixivic/provider/pic_page_model.dart';

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
  Size get preferredSize => Size.fromHeight(ScreenUtil().setHeight(77));
}

class PappBarState extends State<PappBar> {
  double contentHeight;
  double searchBarHeight;
  String title = '日排行';
  String lastHomeTitle;
  String mode;
  TextEditingController searchController;
  TextZhPappBar texts = TextZhPappBar();
  FocusNode searchFocusNode;

//  PageSwitchProvider indexProvider;

  @override
  void initState() {
    if (widget.title != null) title = widget.title;
    lastHomeTitle = title;
    mode = widget.mode;
    searchController = TextEditingController(text: widget.searchKeywordsIn);
    searchFocusNode = FocusNode()..addListener(searchFocusNodeListener);
    contentHeight = ScreenUtil().setHeight(35);
    searchBarHeight = contentHeight;
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Pappbar refresh : " + title);

    return Container(
      color: Colors.white70,
      child: SafeArea(
        top: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 13,
                  offset: Offset(5, 5),
                  color: Color(0x73E5E5E5)),
            ],
          ),
          // height: contentHeight,
          child: Consumer<PageSwitchProvider>(
            builder: (context, PageSwitchProvider indexProvider, _) {
              //判断是否从nav_bar点击
              if (indexProvider.judgePage) {
                changePappbarMode(indexProvider.currentIndex);
                indexProvider.pageChanged(false);
              }
//           }
              return chooseWidget();
            },
          ),
        ),
      ),
    );
  }

  Widget chooseWidget() {
    //TODO: 添加 collection mode
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
        height: contentHeight,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
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
        height: contentHeight,
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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => CommonModel(),
          )
        ],
        child: Consumer<CommonModel>(
          builder: (context, CommonModel heightProvider, _) {
            print("Pappbar refresh : searchbar");
            return AnimatedContainer(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOutExpo,
                // padding: EdgeInsets.only(left: ScreenUtil().setWidth(18)),
                height: searchBarHeight,
                child: SingleChildScrollView(
                    child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: contentHeight,
                          padding:
                              EdgeInsets.only(left: ScreenUtil().setWidth(18)),
                          alignment: Alignment.center,
                          child: FaIcon(
                            FontAwesomeIcons.search,
                            color: Color(0xFF515151),
                            size: ScreenUtil().setWidth(15),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(240),
                          height: ScreenUtil().setHeight(25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFF4F3F3F3),
                          ),
                          margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(10),
                            right: ScreenUtil().setWidth(8),
                          ),
                          child: TextField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            onTap: () {
                              heightProvider.changeHeight(77);
                              searchBarHeight =
                                  ScreenUtil().setHeight(heightProvider.height);
                            },
                            onSubmitted: (value) {
                              widget.searchFucntion(searchController.text);
                            },
                            onChanged: (value) {
                              if (value == '') {
                                widget.searchFucntion(value);
                              }
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '要搜点什么呢',
                              contentPadding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(8),
                                  bottom: ScreenUtil().setHeight(9)),
                            ),
                          ),
                        ),
                        Container(
                          child: InkWell(
                            onTap: () async {
                              bool loginState = hasLogin();
                              if (loginState) {
                                File file = await FilePicker.getFile(
                                    type: FileType.image);
                                if (file != null) {
                                  uploadImageToSaucenao(file, context);
                                } else {
                                  BotToast.showSimpleNotification(
                                      title: texts.noImageSelected);
                                }
                              }
                            },
                            child: Icon(
                              Icons.camera_enhance,
                            ),
                          ),
                        ),
                      ],
                    ),
                    searchBarHeight == contentHeight
                        ? Container()
                        : searchAdditionGroup()
                  ],
                )));
          },
        ));
  }

  Widget searchAdditionGroup() {
    return Container(
      alignment: Alignment.center,
      width: ScreenUtil().setWidth(285),
      margin: EdgeInsets.only(
          top: ScreenUtil().setHeight(8), bottom: ScreenUtil().setHeight(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          searchAdditionCell(texts.transAndSearch,
              onTap: onTranslateThenSearch),
          searchAdditionCell(texts.idToArtist, onTap: onSearchArtistById),
          searchAdditionCell(texts.idToIllust, onTap: onSearchIllustById),
        ],
      ),
    );
  }

  Widget searchAdditionCell(String label, {Function onTap}) {
    return GestureDetector(
      onTap: () {
        if (searchController.text != '') {
          onTap();
        } else {
          BotToast.showSimpleNotification(title: texts.inputError);
        }
      },
      child: Container(
        height: ScreenUtil().setHeight(26),
        width: ScreenUtil().setWidth(89),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(13),
          ),
          boxShadow: [
            BoxShadow(
                blurRadius: 15, offset: Offset(5, 5), color: Color(0x73E5E5E5)),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10),
        ),
      ),
    );
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
            PageSwitchProvider indexProvider =
                Provider.of<PageSwitchProvider>(context, listen: false);
            Navigator.of(context).pop();
            widget.homeModeOptionsFucntion(parameter);
//            setState(() {
            indexProvider.changeTitle(label);
            title = indexProvider.title;
            lastHomeTitle = title;
//            });
          },
          child: Text(label),
        ),
      ),
    );
  }

  void changePappbarMode(int index) {
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
  }

  void changeSearchKeywords(String keywords) {
    setState(() {
      searchController.text = keywords;
    });
  }

  void searchFocusNodeListener() {
    print('searchFocusNodeListener is Lisetning');
    print(
        'Search TextEdit FocusNode: ${searchFocusNode.hasFocus}'); // https://stackoverflow.com/questions/54428029/flutter-how-to-clear-text-field-on-focus
    if (searchFocusNode.hasFocus == false) {
//      setState(() {
      searchBarHeight = contentHeight;
//      });
    } else {
//      setState(() {
      searchBarHeight = ScreenUtil().setHeight(77);
//      });
    }
  }

  onTranslateThenSearch() async {
    var response = await Requests.get(
            'https://api.pixivic.com/keywords/${searchController.text}/translations')
        .catchError((e) {
      print(e);
      BotToast.showSimpleNotification(title: texts.translateError);
    });
    if (response.statusCode == 200) {
      widget.searchFucntion(jsonDecode(response.content())['data']['keyword']);
    } else if (response.statusCode == 400) {
      BotToast.showSimpleNotification(
          title: jsonDecode(response.content())['message']);
    } else {
      BotToast.showSimpleNotification(title: texts.translateError);
    }
  }

  onSearchArtistById() async {
    if (prefs.getString('auth') == '') {
      BotToast.showSimpleNotification(title: texts.pleaseLogin);
      return false;
    } else if (int.tryParse(searchController.text) == null) {
      BotToast.showSimpleNotification(title: texts.inputIsNotNum);
      return false;
    } else {
      CancelFunc cancelLoading = BotToast.showLoading();
      var response = await Requests.get(
              'https://api.pixivic.com/artists/${searchController.text}',
              headers: prefs.getString('auth') != ''
                  ? {'authorization': prefs.getString('auth')}
                  : {})
          .catchError((e) {
        if (e.toString().contains('TimeoutException'))
          BotToast.showSimpleNotification(title: texts.searchTimeout);
        else
          BotToast.showSimpleNotification(title: texts.networkError);
        cancelLoading();
        return false;
      });
      cancelLoading();
      Map result = jsonDecode(response.content());
      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ArtistPage(
              result['data']['avatar'],
              result['data']['name'],
              result['data']['id'].toString(),
              isFollowed: prefs.getString('auth') != ''
                  ? result['data']['isFollowed']
                  : false,
            );
          },
        ));
        return true;
      } else if (response.statusCode == 400) {
        print('search artist 400');
        BotToast.showSimpleNotification(title: result['message']);
        return false;
      } else {
        BotToast.showSimpleNotification(title: result['message']);
        return false;
      }
    }
  }

  onSearchIllustById() async {
    if (prefs.getString('auth') == '') {
      BotToast.showSimpleNotification(title: texts.pleaseLogin);
      return false;
    } else if (int.tryParse(searchController.text) == null) {
      BotToast.showSimpleNotification(title: texts.inputIsNotNum);
      return false;
    } else {
      CancelFunc cancelLoading = BotToast.showLoading();
      var response = await Requests.get(
              'https://api.pixivic.com/illusts/${searchController.text}',
              headers: prefs.getString('auth') != ''
                  ? {'authorization': prefs.getString('auth')}
                  : {})
          .catchError((e) {
        if (e.toString().contains('TimeoutException'))
          BotToast.showSimpleNotification(title: texts.searchTimeout);
        else
          BotToast.showSimpleNotification(title: texts.networkError);
        cancelLoading();
        return false;
      });
      cancelLoading();
      Map result = jsonDecode(response.content());
      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return PicDetailPage(result['data']);
          },
        ));
        return true;
      } else if (response.statusCode == 404) {
        BotToast.showSimpleNotification(title: result['message']);
        return false;
      }
    }
  }
}
