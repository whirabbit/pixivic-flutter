import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:random_color/random_color.dart';
import 'package:lottie/lottie.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/data/common.dart';
import 'package:pixivic/data/texts.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/widget/image_display.dart';
import 'package:pixivic/function/dio_client.dart';

class GuessLikePage extends StatefulWidget {
  @override
  _GuessLikePageState createState() => _GuessLikePageState();
}

class _GuessLikePageState extends State<GuessLikePage> {
  bool hasConnected = false;
  List picList;
  int picTotalNum;

  int sanityLevel = prefs.getInt('sanityLevel');
  int previewRule = prefs.getInt('previewRule');
  String previewQuality = prefs.getString('previewQuality');

  RandomColor ramdomColor = RandomColor();
  TextZhGuessLikePage texts = TextZhGuessLikePage();
  ScrollController scrollController = ScrollController();
  bool isScrollAble = true;

  @override
  void initState() {
    _getJsonList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PappBar(
          title: texts.title,
        ),
        body: guessLikeBody(),
        floatingActionButton: refreshButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  Widget guessLikeBody() {
    if (picList == null && !hasConnected) {
      return Container(
          height: ScreenUtil().setHeight(576),
          width: ScreenUtil().setWidth(324),
          alignment: Alignment.center,
          color: Colors.white,
          child: Center(
            child: Lottie.asset('image/loading-box.json'),
          ));
    } else if (picList == null && hasConnected) {
      return nothingHereBox();
    } else {
      return Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(5), right: ScreenUtil().setWidth(5)),
          color: Colors.grey[50],
          child: WaterfallFlow.builder(
            controller: scrollController,
            physics: isScrollAble
                ? ClampingScrollPhysics()
                : NeverScrollableScrollPhysics(),
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: picTotalNum,
            itemBuilder: (BuildContext context, int index) => oldImageCell(
                picList[index],
                ramdomColor,
                sanityLevel,
                previewRule,
                previewQuality,
                context),
            // staggeredTileBuilder: (index) => StaggeredTile.fit(1),
            // mainAxisSpacing: 0.0,
            // crossAxisSpacing: 0.0,
          ));
    }
  }

  Widget refreshButton() {
    return FloatingActionButton(
      child: Icon(Icons.refresh),
      backgroundColor: Colors.orange[200],
      onPressed: () async {
        setState(() {
          picList = null;
          hasConnected = false;
        });
        await _getJsonList();
        setState(() {});
      },
    );
  }

  _getJsonList() async {
    String url = '/users/${prefs.getInt('id')}/recommendBookmarkIllusts';

    try {
      Response response = await dioPixivic.get(url);
      picList = response.data['data'];
      if (picList != null) picTotalNum = picList.length;
      setState(() {
        hasConnected = true;
        print(picList);
      });
    } catch (e) {}
  }
}
