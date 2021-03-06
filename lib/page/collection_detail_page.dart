import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import 'package:pixivic/page/pic_page.dart';
import 'package:pixivic/widget/papp_bar.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/function/collection.dart';
import 'package:pixivic/provider/collection_model.dart';

class CollectionDetailPage extends StatelessWidget {
  final int index;

  CollectionDetailPage(this.index);

  @override
  Widget build(BuildContext context) {
    return Selector<CollectionUserDataModel, Map>(
        selector: (context, collectionUserDataModel) =>
            collectionUserDataModel.userCollectionList[index],
        builder: (context, basicData, _) {
          return Scaffold(
              appBar: PappBar.collection(
                title: basicData['title'],
                collectionSetting: collectionSetting,
              ),
              body: Container(
                color: Colors.white,
                child: PicPage.collection(
                  collectionId: basicData['id'].toString(),
                  topWidget: collectionDetailBody(basicData),
                ),
              ));
        });
  }

  Widget collectionDetailBody(Map basicData) {
    final screen = ScreenUtil();

    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: screen.setWidth(18),
                top: screen.setHeight(18),
                bottom: screen.setHeight(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: screen.setWidth(25),
                  width: screen.setWidth(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: screen.setWidth(1), color: Colors.grey[300]),
                  ),
                  margin: EdgeInsets.only(
                    right: screen.setWidth(18),
                  ),
                  child: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.all(
                          Radius.circular(screen.setWidth(25))),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        constraints: BoxConstraints(
                          minHeight: screen.setWidth(25),
                          minWidth: screen.setWidth(25),
                        ),
                        child: Image(
                            image: AdvancedNetworkImage(
                          prefs.getString('avatarLink'),
                          useDiskCache: true,
                          timeoutDuration: const Duration(seconds: 35),
                          cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                          header: {'referer': 'https://m.sharemoe.net/'},
                        )),
                      )),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: screen.setWidth(231)),
                  child: Text(
                    basicData['title'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: screen.setSp(14)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
                left: screen.setWidth(18),
                right: screen.setWidth(18),
                bottom: screen.setHeight(12)),
            child: Text(
              basicData['caption'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.w400, fontSize: screen.setSp(12)),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                  left: screen.setWidth(18),
                  right: screen.setWidth(18),
                  bottom: screen.setHeight(12)),
              child: Wrap(
                children: List.generate(basicData['tagList'].length,
                    (index) => tagLink(basicData['tagList'][index]['tagName'])),
              )),
          // Flexible(
          //   // constraints: BoxConstraints(maxHeight: screen.setHeight(360),),
          //   child: PicPage.collection(collectionId: basicData['id'].toString()),
          // )
        ],
      ),
    );
  }

  Widget tagLink(String tag) {
    return Container(
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(2)),
        child: Text(
          '#$tag',
          style: TextStyle(
              color: Colors.orange[300],
              fontWeight: FontWeight.w400,
              fontSize: ScreenUtil().setSp(12)),
        ));
  }

  collectionSetting(BuildContext context) {
    print('collectionSetting run');
    showCollectionInfoEditDialog(context, isCreate: false, index: index);
  }
}
