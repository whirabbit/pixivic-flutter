import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/result.dart';

part 'wallpaper_rest_client.g.dart';

@Injectable()
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class WallpaperRestClient {
  @factoryMethod
  factory WallpaperRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _WallpaperRestClient;

  @GET("/wallpaper/category/{categotyId}/tags/{tagId}/type/{type}/illusts")
  Future<Result<List<Illust>>> queryIllustUnderTagListInfo(
    @Path("categotyId") int categotyId,
    @Path("tagId") int tagId,
    @Path("type") String type,
    @Query("offset") double offset,
    @Query("pageSize") int pageSize,
  );
}
