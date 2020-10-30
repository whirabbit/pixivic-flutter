import 'package:flutter/material.dart';
import 'package:pixivic/provider/collection_model.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import 'package:pixivic/page/pic_page.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/data/common.dart';

//TODO: 001 finish this from figma

class CollectionDetailPage extends StatelessWidget {
  final int collectionId;
  final String title;

  CollectionDetailPage(this.collectionId, this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(title: title),
      body: PicPage.collection(collectionId: collectionId.toString()),
    );
  }

  Widget collectionDetailBody() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(18),
          right: ScreenUtil().setWidth(18),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  constraints: BoxConstraints(
                    minHeight: ScreenUtil().setWidth(25),
                    minWidth: ScreenUtil().setWidth(25),
                  ),
                  child: Image(
                      image: AdvancedNetworkImage(
                    prefs.getString('avatarLink'),
                    useDiskCache: true,
                    timeoutDuration: const Duration(seconds: 35),
                    cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    header: {'referer': 'https://pixivic.com'},
                  )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
