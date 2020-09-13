import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

import 'package:pixivic/page/search_page.dart';
import 'package:pixivic/widget/nav_bar.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/page/pic_page.dart';
import 'package:pixivic/page/new_page.dart';
import 'package:pixivic/page/user_page.dart';
import 'package:pixivic/page/center_page.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/bugly.dart';
import 'package:pixivic/function/update.dart';
import 'package:pixivic/function/collection.dart';
import 'package:pixivic/provider/page_switch.dart';

// import 'provider/comment_list_model.dart';
// import 'provider/pic_page_model.dart';
// import 'widget/menu_button.dart';
// import 'widget/menu_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  FlutterBugly.postCatchedException(() {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageSwitchProvider()),
        ChangeNotifierProvider<NewCollectionParameterModel>(
          create: (_) => NewCollectionParameterModel(),
        )
      ],
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver()],
        title: 'Pixivic',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Pixivic'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('zh', 'CH'),
          const Locale('en', 'US'),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // TextEditingController _textFieldController = TextEditingController();

  int _currentIndex = 0;
  bool _navBarAlone = true;

  // bool _isPageScrolling = false;
  var _pageController = PageController(initialPage: 0);

  DateTime _picDate =
      DateTime.now().subtract(Duration(hours: 39)); //当前时间，初始化时默认最新时间
  String _picDateStr = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(hours: 39)));
  String _picMode = 'day';
  DateTime _picLastDate =
      DateTime.now().subtract(Duration(hours: 39)); //日历显示的最新时间
  DateTime _picFirstDate = DateTime(2008, 1, 1); //日历显示的最早时间

  // GlobalKey<MenuButtonState> _menuButtonKey = GlobalKey();
  // GlobalKey<MenuListState> _menuListKey = GlobalKey();
  // GlobalKey<PappBarState> _pappBarKey = GlobalKey();

  PicPage picPage;
  UserPage userPage;
  CenterPage centerPage;
  NewPage newPage;
  PappBar pappBar;

  PageSwitchProvider indexProvider;

  String updateTaskId;
  String apkPath;

  @override
  void initState() {
    FlutterBugly.init(
            androidAppId: buglyAndroid,
            iOSAppId: buglyIos,
            autoCheckUpgrade: false)
        .then((onValue) {
      print('FlutterBugly: ${onValue.isSuccess}');
      print('FlutterBugly: ${onValue.appId}');
      print('FlutterBugly: ${onValue.message}');
      FlutterBugly.setUserId('pixivic 0.1.0');
      if (Theme.of(context).platform == TargetPlatform.android) {
        FlutterBugly.checkUpgrade().then((UpgradeInfo info) {
          print('==============checkUpgrade============');
          if (info != null && info.id != null) {
            UpdateApp().showUpdateDialog(
                context, info.versionName, info.newFeature, info.apkUrl);
          }
        });
      }
    });
    FlutterDownloader.initialize(debug: false).then((value) {
      FlutterDownloader.cancelAll();
    });

    initData().then((value) {
      setState(() {
        picPage = PicPage.home(
          picDate: _picDateStr,
          picMode: _picMode,
        );

        userPage = UserPage(userPageKey);
        newPage = NewPage(newPageKey);
        centerPage = CenterPage();
        pappBar = PappBar.home(
          homeModeOptionsFucntion: _onOptionCellTap,
//          key: _pappBarKey,
        );
      });
    });

    super.initState();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 324, height: 576);
    print("Reload main build func");
    indexProvider = Provider.of<PageSwitchProvider>(context);
    return Scaffold(
      appBar: pappBar,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: 4, //页面数量
            onPageChanged: _onPageChanged, //页面切换
            controller: _pageController,
            itemBuilder: (context, index) {
              return Center(
                child: _getPageByIndex(index), //每个页面展示的组件
              );
            },
          ),
          NavBar(_currentIndex, _onNavbarTap, _navBarAlone),
          // MenuButton(_onMenuButoonTap, _menuButtonKey),
          // MenuList(_onOptionCellTap, _menuListKey),
        ],
      ),
    );
  }

  Widget _getPageByIndex(int index) {
    switch (index) {
      case 0:
        return picPage;
      case 1:
        return centerPage;
      case 2:
        return newPage;
      case 3:
        return userPage;
      default:
        return picPage;
    }
  }

  _onNavbarTap(int index) {
    // print('tap $index');
    //    setState(() {
//      _currentIndex = index;
//    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  _onPageChanged(int index) {
    // print('_onPageChanged: $index');
//      _currentIndex = index;
    indexProvider.changeIndex(index);
    //滑动切换类似点击nav_bar
    indexProvider.changeJudge(true);
    // _menuButtonKey.currentState.changeTapState(false);
    // _menuListKey.currentState.changeActive(false);

    // if (index == 0) {
    //   _navBarAlone = false;
    //   _menuButtonKey.currentState.changeVisible(true);
    // } else {
    //   _navBarAlone = true;
    //   _menuButtonKey.currentState.changeVisible(false);
    // }
//      _pappBarKey.currentState.changePappbarMode(index);
//      _onPageScrolling(false);
  }

  // void _onMenuButoonTap() {
  //   _menuButtonKey.currentState.flipTapState();
  //   _menuListKey.currentState.flipActive();
  // }

  _onOptionCellTap(String parameter) async {
    // calendar chooser
    if (parameter == 'new_date') {
      DateTime newDate = await showDatePicker(
        context: context,
        initialDate: _picDate,
        firstDate: _picFirstDate,
        lastDate: _picLastDate,
        locale: Locale('zh'),
      );
      print('The newDate is : $newDate');
      if (newDate != null) {
        // _menuButtonKey.currentState.flipTapState();
        // _menuListKey.currentState.flipActive();
        setState(() {
          print(newDate);
          _picDate = newDate;
          _picDateStr = DateFormat('yyyy-MM-dd').format(_picDate);
          picPage = PicPage.home(
            picDate: _picDateStr,
            picMode: _picMode,
          );
        });
      }
    } else if (parameter == 'search') {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SearchPage(searchKeywordsIn: '')),
      );
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //       title: Text(
      //         '搜索关键词',
      //         style: TextStyle(
      //             color: Color(0xFF515151), fontWeight: FontWeight.w300),
      //       ),
      //       content: TextField(
      //         autofocus: true,
      //         controller: _textFieldController,
      //         decoration: InputDecoration(
      //             border: InputBorder.none,
      //             hintText: '要搜点什么呢',
      //             contentPadding:
      //                 EdgeInsets.only(bottom: ScreenUtil().setHeight(8))),
      //       ),
      //       actions: <Widget>[
      //         new FlatButton(
      //           child: new Text('提交'),
      //           onPressed: () {
      //             String input = _textFieldController.text;
      //             if (input == '') {
      //               Navigator.of(context).pop();
      //             } else {
      //               Navigator.of(context).pop();
      //               Navigator.of(context).push(
      //                 MaterialPageRoute(
      //                     builder: (context) =>
      //                         SearchPage(searchKeywordsIn: input)),
      //               );
      //               // _menuButtonKey.currentState.flipTapState();
      //               // _menuListKey.currentState.flipActive();
      //               _textFieldController.clear();
      //             }
      //           },
      //         )
      //       ],
      //     );
      //   },
      // );
    } else {
      // _menuButtonKey.currentState.flipTapState();
      // _menuListKey.currentState.flipActive();
//      setState(() {
      _picMode = parameter;
      picPage = PicPage.home(
        picDate: _picDateStr,
        picMode: _picMode,
//          onPageScrolling: _onPageScrolling,
      );
//      });
    }
  }

//  _onPageScrolling(bool isScrolling) {
//    if (isScrolling) {
//      setState(() {
//        _isPageScrolling = true;
//      });
//    } else {
//      setState(() {
//        _isPageScrolling = false;
//      });
//    }
//  }

}
