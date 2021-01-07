import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/result.dart';

part 'user_rest_client.g.dart';

@Injectable()
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class UserRestClient {
  @factoryMethod
  factory UserRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _UserRestClient;

  @GET("/users/{userId}/followedWithRecentlyIllusts")
  Future<Result<List<Artist>>> queryFollowedWithRecentlyIllustsInfo(
      @Path("userId") int userId,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

  @GET("/users/{userId}/followed/latest/{type}")
  Future<Result<List<Illust>>> queryUserFollowedLatestIllustListInfo(
      @Path("userId") int userId,
      @Path("type") String type,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

//收藏画作
  @GET("/users/{userId}/bookmarked/{type}")
  Future<Result<List<Illust>>> queryUserCollectIllustListInfo(
      @Path("userId") int userId,
      @Path("type") String type,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

  @GET("/users/{userId}/illustHistory")
  Future<Result<List<Illust>>> queryHistoryListInfo(
    @Path("userId") String userId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

  @GET("/users/{userId}/oldIllustHistory")
  Future<Result<List<Illust>>> queryOldHistoryListInfo(
    @Path("userId") String userId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

//画集
  @GET("/collections/{collectionId}/illustrations")
  Future<Result<List<Illust>>> queryCollectionListInfo(
    @Path("collectionId") int collectionId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );
}
