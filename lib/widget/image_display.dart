///  此类包含了用于图片展示的组件，包含
///  - 单个图片单元
///  - 数字展示
///  - 收藏的心形按钮
///  - "这里什么都没有"的图像
///  - "列表加载中的"的图像

import 'package:flutter/material.dart';

import 'package:random_color/random_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:pixivic/page/pic_detail_page.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/function/image_url.dart';
import 'package:pixivic/provider/pic_page_model.dart';
import 'package:pixivic/widget/markheart_icon.dart';

Widget imageCell(
    Map picItem, int index, BuildContext context, PicPageModel picPageModel) {
  final Color color = RandomColor().randomColor();
  Map picMapData = Map.from(picItem);
  if (picMapData['xrestict'] == 1 ||
      picMapData['sanityLevel'] > prefs.getInt('sanityLevel'))
    return Container();
  else
    return Selector<PicPageModel, Tuple2<bool, bool>>(
        selector: (context, picPageModel) => Tuple2(
            // 前者用于判断当前画作是否被选中
            // 后者用于判断当前是否出于多选模式，这会导致单击的逻辑更改
            picPageModel.isIndexInSelectedList(index),
            picPageModel.isInSelectMode()),
        builder: (context, tuple, _) {
          return AnimatedContainer(
              duration: Duration(milliseconds: 350),
              padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(5),
                right: ScreenUtil().setWidth(5),
                top: ScreenUtil().setWidth(5),
                bottom: ScreenUtil().setWidth(5),
              ),
              child: ShaderMask(
                shaderCallback: (tuple.item1)
                    // 长按进入选择模式时，为选中的画作设置遮罩
                    ? (bounds) => LinearGradient(
                            colors: [Colors.grey[600], Colors.grey[600]])
                        .createShader(bounds)
                    : (bounds) =>
                        LinearGradient(colors: [Colors.white, Colors.white])
                            .createShader(bounds),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: GestureDetector(
                        onTap: () async {
                          // 如果不是在多选模式，则正常进行跳转
                          if (!tuple.item2) {
                            // 对广告图片做区分判断
                            if (picMapData['type'] == 'ad_image') {
                              if (await canLaunch(picMapData['link'])) {
                                await launch(picMapData['link']);
                              } else {
                                BotToast.showSimpleNotification(
                                    title: '唤起网页失败');
                                throw 'Could not launch ${picMapData['link']}';
                              }
                            } else
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PicDetailPage(
                                          picMapData,
                                          index: index,
                                          getPageProvider: picPageModel)));
                          } else {
                            Provider.of<PicPageModel>(context, listen: false)
                                .handlePicIndexToSelectedList(index);
                          }
                        },
                        onLongPress: () {
                          Provider.of<PicPageModel>(context, listen: false)
                              .handlePicIndexToSelectedList(index);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 350),
                          // 限定constraints用于占用位置,经调试后以0.5为基准可以保证加载图片后不产生位移
                          constraints: BoxConstraints(
                            minHeight: ScreenUtil().setWidth(148) /
                                picItem['width'].toDouble() *
                                picItem['height'].toDouble(),
                            minWidth: ScreenUtil().setWidth(148),
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              // 若被选中，则添加边框
                              border: tuple.item1
                                  ? Border.all(
                                      width: ScreenUtil().setWidth(3),
                                      color: Colors.black38)
                                  : Border.all(width: 0.0, color: Colors.white),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(ScreenUtil().setWidth(15)))),
                          child: Hero(
                            tag: 'imageHero' +
                                picItem['imageUrls'][0]
                                    [prefs.getString('previewQuality')],
                            child: ClipRRect(
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ScreenUtil().setWidth(12))),
                                child: pureImage(picItem, color)),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: numberViewer(picItem['pageCount']),
                      right: ScreenUtil().setWidth(10),
                      top: ScreenUtil().setHeight(5),
                    ),
                    prefs.getString('auth') != '' &&
                            picMapData['type'] != 'ad_image'
                        ? Positioned(
                            bottom: ScreenUtil().setHeight(5),
                            right: ScreenUtil().setWidth(5),
                            child: Container(
                                alignment: Alignment.center,
                                height: ScreenUtil().setWidth(33),
                                width: ScreenUtil().setWidth(33),
                                child: Selector<PicPageModel, bool>(
                                  selector: (context, provider) =>
                                      provider.picList[index]['isLiked'],
                                  builder: (context, isLike, _) {
                                    return MarkHeart(
                                        picItem: picItem,
                                        index: index,
                                        getPageProvider: picPageModel);
                                  },
                                )))
                        : Container(),
                  ],
                ),
              ));
        });
}

Image pureImage(Map picItem, Color color) {
  return Image(
    image: AdvancedNetworkImage(
      imageUrl(picItem['imageUrls'][0]['medium'], 'medium'),
      header: imageHeader('medium'),
      useDiskCache: true,
      cacheRule: CacheRule(maxAge: Duration(days: prefs.getInt('previewRule'))),
      // loadFailedCallback: () {
      //   prefs.setBool('isOnPixivicServer', true);
      // },
    ),
    fit: BoxFit.fill,
    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      if (wasSynchronouslyLoaded) {
        return child;
      }
      return Container(
        child: AnimatedOpacity(
          child: frame == null ? Container(color: color) : child,
          opacity: frame == null ? 0.3 : 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
        ),
      );
    },
  );
}

Widget oldImageCell(Map picMapData, RandomColor randomColor, int sanityLevel,
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
                        cacheRule:
                            CacheRule(maxAge: Duration(days: previewRule)),
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
            child: numberViewer(number),
            right: ScreenUtil().setWidth(10),
            top: ScreenUtil().setHeight(5),
          ),
          prefs.getString('auth') != '' && picMapData['type'] != 'ad_image'
              ? Positioned(
                  bottom: ScreenUtil().setHeight(5),
                  right: ScreenUtil().setWidth(5),
                  child: BookMarkHeart(picMapData))
              : Container(),
        ],
      ),
    );
}

Widget numberViewer(num numberOfPic) {
  return (numberOfPic != 1)
      ? Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
          decoration: BoxDecoration(
              color: Colors.black38, borderRadius: BorderRadius.circular(3)),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.content_copy,
                color: Colors.white,
                size: ScreenUtil().setWidth(10),
              ),
              Text(
                '$numberOfPic',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil().setHeight(10),
                    decoration: TextDecoration.none),
              ),
            ],
          ),
        )
      : Container();
}

class BookMarkHeart extends StatefulWidget {
  @override
  _BookMarkHeartState createState() => _BookMarkHeartState();

  final Map picMapData;

  BookMarkHeart(this.picMapData);
}

class _BookMarkHeartState extends State<BookMarkHeart> {
  Map picMapData;

  @override
  void initState() {
    picMapData = widget.picMapData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLikedLocalState = picMapData['isLiked'];
    var color = isLikedLocalState ? Colors.redAccent : Colors.grey[300];
    String picId = picMapData['id'].toString();

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
      alignment: Alignment.center,
      // color: Colors.white,
      height: isLikedLocalState
          ? ScreenUtil().setWidth(33)
          : ScreenUtil().setWidth(27),
      width: isLikedLocalState
          ? ScreenUtil().setWidth(33)
          : ScreenUtil().setWidth(27),
      child: GestureDetector(
        onTap: () async {
          String url = '/users/bookmarked';
          Map<String, String> body = {
            'userId': prefs.getInt('id').toString(),
            'illustId': picId.toString(),
            'username': prefs.getString('name')
          };

          if (isLikedLocalState) {
            await dioPixivic.delete(
              url,
              data: body,
            );
            setState(() {
              picMapData['isLiked'] = false;
            });
          } else {
            await dioPixivic.post(
              url,
              data: body,
            );
            setState(() {
              picMapData['isLiked'] = true;
            });
          }
        },
        child: LayoutBuilder(builder: (context, constraint) {
          return Icon(Icons.favorite,
              color: color, size: constraint.biggest.height);
        }),
      ),
    );
  }
}

Widget nothingHereBox({bool isFullScreen}) {
  return Container(
    height: ScreenUtil().setHeight(576),
    width: ScreenUtil().setWidth(324),
    color: Colors.white,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Lottie.asset('image/empty-box.json',
            repeat: false, height: ScreenUtil().setHeight(100)),
        Text(
          '这里什么都没有呢',
          style: TextStyle(
              color: Colors.grey,
              fontSize: ScreenUtil().setHeight(10),
              decoration: TextDecoration.none),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(250),
        )
      ],
    ),
  );
}

Widget loadingBox({bool isFullScreen = true}) {
  if (isFullScreen)
    return Container(
        height: ScreenUtil().setHeight(576),
        width: ScreenUtil().setWidth(324),
        alignment: Alignment.center,
        color: Colors.white,
        child: Center(
          child: Lottie.asset('image/loading-box.json'),
        ));
  else
    return Center(
      child: Container(
          // height: ScreenUtil().setHeight(576),
          // width: ScreenUtil().setWidth(324),
          alignment: Alignment.center,
          color: Colors.white,
          child: Center(
            child: Lottie.asset('image/loading-box.json'),
          )),
    );
}
