import 'package:flutter/material.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:pixivic/provider/meme_model.dart';
import 'package:provider/provider.dart';

import 'package:pixivic/widget/image_display.dart';
import 'package:pixivic/provider/comment_list_model.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class MemeBox extends StatelessWidget {
  final num widgetHeight;

  MemeBox(this.widgetHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScreenUtil().setWidth(324),
        height: widgetHeight,
        color: Colors.grey[100],
        child: Consumer<MemeModel>(builder: (context, memeModel, _) {
          if (memeModel.memeMap == null)
            return loadingBox();
          else {
            List memeGroupKeys = memeModel.memeMap.keys.toList();
            return DefaultTabController(
                length: 3,
                child: Column(children: [
                  Container(
                    color: Colors.white,
                    width: ScreenUtil().setWidth(324),
                    height: ScreenUtil().setHeight(30),
                    child: TabBar(
                      labelColor: Colors.orange[400],
                      tabs: List.generate(memeGroupKeys.length,
                          (index) => Tab(text: memeGroupKeys[index])),
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(324),
                    height: widgetHeight - ScreenUtil().setHeight(30),
                    alignment: Alignment.center,
                    child: TabBarView(
                        children: List.generate(memeGroupKeys.length,
                            (index) => memePanel(memeGroupKeys[index]))),
                  )
                ]));
          }
        }));
  }

  Widget memePanel(String memeGroup) {
    return Consumer<MemeModel>(builder: (context, memeModel, _) {
      if (memeModel.memeMap == null)
        return loadingBox();
      else {
        List memeKeys = memeModel.memeMap[memeGroup].keys.toList();
        List memePath = memeModel.memeMap[memeGroup].values.toList();
        // return SingleChildScrollView(
        //   child: Wrap(
        //       crossAxisAlignment: WrapCrossAlignment.center,
        //       alignment: WrapAlignment.center,
        //       runAlignment: WrapAlignment.start,
        //       children: List.generate(
        //           memeKeys.length,
        // (index) => memeCell(
        //     context, memePath[index], memeKeys[index], memeGroup))),
        // );
        return WaterfallFlow.builder(
            itemCount: memeKeys.length,
            itemBuilder: (BuildContext context, int index) {
              return memeCell(
                  context, memePath[index], memeKeys[index], memeGroup);
            },
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              viewportBuilder: (int firstIndex, int lastIndex) {
                print("memebox viewport : [$firstIndex,$lastIndex]");
              },
            ));
      }
    });
  }

  Widget memeCell(
      BuildContext context, String path, String memeName, String memeGroup) {
    return GestureDetector(
      onTap: () {
        print('memeCell onTap$memeName');
        Provider.of<CommentListModel>(context, listen: false)
            .replyMeme(memeGroup, memeName);
      },
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.all(ScreenUtil().setWidth(4)),
        width: ScreenUtil().setWidth(55),
        height: ScreenUtil().setWidth(55),
        child: Image(
          isAntiAlias: true,
          image: (AssetImage(path)),
        ),
      ),
    );
  }
}
