import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/provider/favorite_animation_model.dart';
import 'package:pixivic/provider/pic_page_model.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/biz/user/service/user_service.dart';
import 'package:pixivic/common/config/get_it_config.dart';

class MarkHeart extends StatelessWidget {
  MarkHeart(
      {@required this.picItem,
      @required this.index,
      @required this.getPageProvider});

  final Illust picItem;
  final int index;

  final PicPageModel getPageProvider;

  @override
  Widget build(BuildContext context) {
    // print('Build MarkHeart $index');
    bool isLikedLocalState = getPageProvider != null
        ? getPageProvider.picList[index].isLiked
        : picItem.isLiked;
    Color color = isLikedLocalState ? Colors.redAccent : Colors.grey[300];
    String picId = picItem.id.toString();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoriteAnimationModel>(
          create: (_) => FavoriteAnimationModel(),
        )
      ],
      child: Consumer<FavoriteAnimationModel>(
        builder: (context, FavoriteAnimationModel favProvider, child) {
          return IconButton(
            color: color,
            padding: EdgeInsets.all(0),
            iconSize: ScreenUtil().setHeight(favProvider.iconSize),
            icon: Icon(Icons.favorite),
            onPressed: () async {
              //点击动画
              favProvider.clickFunc();
              String url = '/users/bookmarked';
              Map<String, String> body = {
                'userId': prefs.getInt('id').toString(),
                'illustId': picId.toString(),
                'username': prefs.getString('name')
              };
              try {
                if (isLikedLocalState) {
                  await getIt<UserService>().queryUserCancelMarkIllust(body);
                  // await dioPixivic.delete(
                  //   url,
                  //   data: body,
                  // );
                } else {
                  await getIt<UserService>().queryUserMarkIllust(body);
                  // await dioPixivic.post(
                  //   url,
                  //   data: body,
                  // );
                }
                Future.delayed(Duration(milliseconds: 400), () {
                  getPageProvider != null
                      ? getPageProvider.flipLikeState(index)
                      : picItem.isLiked = !picItem.isLiked;
                  isLikedLocalState = !isLikedLocalState;
                  color =
                      isLikedLocalState ? Colors.redAccent : Colors.grey[300];
                });
              } catch (e) {}
            },
          );
        },
      ),
    );
  }
}
