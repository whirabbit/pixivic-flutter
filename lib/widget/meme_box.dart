import 'package:flutter/material.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:pixivic/provider/meme_model.dart';
import 'package:provider/provider.dart';

import 'package:pixivic/widget/image_display.dart';

class MemeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: ScreenUtil().setWidth(324),
        height: ScreenUtil().setHeight(256),
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
                    height: ScreenUtil().setHeight(226),
                    alignment: Alignment.center,
                    child: TabBarView(
                        children: List.generate(memeGroupKeys.length,
                            (index) => memePanel(memeGroupKeys[index]))),
                  )
                ]));
          }
        }));
  }

  Widget memePanel(String key) {
    return Consumer<MemeModel>(builder: (context, memeModel, _) {
      if (memeModel.memeMap == null)
        return loadingBox();
      else {
        List memeKeys = memeModel.memeMap[key].keys.toList();
        List memePath = memeModel.memeMap[key].values.toList();
        return SingleChildScrollView(
          child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.start,
              children: List.generate(memeKeys.length,
                  (index) => memeCell(memePath[index], memeKeys[index]))),
        );
      }
    });
  }

  Widget memeCell(String path, String memeName) {
    return GestureDetector(
      onTap: () {
        print('onTap memeCell $memeName');
      },
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.all(ScreenUtil().setWidth(4)),
        width: ScreenUtil().setWidth(55),
        height: ScreenUtil().setWidth(55),
        child: Image(
          image: (AssetImage(path)),
        ),
      ),
    );
  }
}
