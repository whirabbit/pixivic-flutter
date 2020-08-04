import 'package:flutter/material.dart';

import 'package:random_color/random_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

import '../page/pic_detail_page.dart';
import '../data/common.dart';

Widget imageCell(Map picMapData, RandomColor randomColor, int sanityLevel,
    int previewRule, String previewQuality, BuildContext context) {
  final Color color = randomColor.randomColor();
  String url = picMapData['imageUrls'][0][previewQuality]; //medium large
  int number = picMapData['pageCount'];
  double width = picMapData['width'].toDouble();
  double height = picMapData['height'].toDouble();
  if (picMapData['xrestict'] == 1 || picMapData['sanityLevel'] > sanityLevel)
    return Container();
  else
    return Container(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(5),
        right: ScreenUtil().setWidth(5),
        top: ScreenUtil().setWidth(10),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(15),
              child: GestureDetector(
                onTap: () async {
                  // 对广告图片做区分判断
                  if (picMapData['type'] == 'ad_image') {
                    if (await canLaunch(picMapData['link'])) {
                      await launch(picMapData['link']);
                    } else {
                      BotToast.showSimpleNotification(title: '唤起网页失败');
                      throw 'Could not launch ${picMapData['link']}';
                    }
                  } else
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PicDetailPage(
                                  picMapData,
                                )));
                },
                child: Container(
                  // 限定constraints用于占用位置,经调试后以0.5为基准可以保证加载图片后不产生位移
                  constraints: BoxConstraints(
                      // minHeight: MediaQuery.of(context).size.width *
                      //     0.5 /
                      //     _picMainParameter(index)[2] *
                      //     _picMainParameter(index)[3],
                      // minWidth: MediaQuery.of(context).size.width * 0.41,
                      minHeight: ScreenUtil().setWidth(148) / width * height,
                      minWidth: ScreenUtil().setWidth(148)),
                  child: Hero(
                    tag: 'imageHero' + url,
                    child: Image(
                      image: AdvancedNetworkImage(
                        url,
                        header: {'Referer': 'https://app-api.pixiv.net'},
                        useDiskCache: true,
                        cacheRule: CacheRule(
                            maxAge:
                                Duration(days: previewRule)),
                      ),
                      fit: BoxFit.fill,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) {
                          return child;
                        }
                        return Container(
                          child: AnimatedOpacity(
                            child:
                                frame == null ? Container(color: color) : child,
                            opacity: frame == null ? 0.3 : 1,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeOut,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: numberViewer(_picMainParameter(index)[1]),
            right: ScreenUtil().setWidth(10),
            top: ScreenUtil().setHeight(5),
          ),
          prefs.getString('auth') != '' && picMapData['type'] != 'ad_image'
              ? Positioned(
                  bottom: ScreenUtil().setHeight(5),
                  right: ScreenUtil().setWidth(5),
                  child: bookmarkHeart(index))
              : Container(),
        ],
      ),
    );
}
