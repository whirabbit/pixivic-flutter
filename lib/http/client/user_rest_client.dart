import 'package:dio/dio.dart';
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

//用户收藏画作
  @GET("/users/bookmarked")
  Future<String> queryUserMarkIllustInfo(@Body() Map body);

//用户获取收藏画作列表
  @GET("/users/{userId}/bookmarked/{type}")
  Future<Result<List<Illust>>> queryUserCollectIllustListInfo(
      @Path("userId") int userId,
      @Path("type") String type,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

//用户取消收藏画作
  @DELETE("/users/bookmarked")
  Future<String> queryUserCancelMarkIllustInfo(@Body() Map body);

  //查询画作是否被当前用户收藏
  @GET("/users/{userId}/{illustId}/isBookmarked")
  Future<Result> queryIsIllustMarkedInfo(
    @Path("userId") int userId,
    @Path("illustId") int illustId,
  );

  //用户关注画师
  @POST("/users/followed")
  Future<String> queryUserMarkArtistInfo(
    @Body() Map body,
  );

  //用户取消收藏画师
  @DELETE("/users/followed")
  Future<String> queryUserCancelMarkArtistInfo(
    @Body() Map body,
  );

//获取用户关注画师
  @GET("/users/{userId}/followed")
  Future<Result<List<Artist>>> queryGetUserMarkArtistListInfo(
      @Query("page") int page, @Query("pageSize") int pageSize);

  //获取用户是否关注画师
  @GET("/users/{userId}/{artistId}/isFollowed")
  Future<Result<bool>> queryIsUserMarkArtistInfo(
      @Path("userId") int userId, @Path("artistId") int artistId);

  ///图片上传  特殊接口 请参照文档  /https://pic.pixivic.com/upload
  //关注画师最新画作
  @GET("/users/{userId}/followed/latest/{type}")
  Future<Result<List<Illust>>> queryUserFollowedLatestIllustListInfo(
      @Path("userId") int userId,
      @Path("type") String type,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

//新增用户查看画作历史记录
  @POST("/users/{userId}/illustHistory")
  Future<String> queryNewUserViewIllustHistoryInfo(
    @Path("userId") int userId,
    @Body() Map body,
  );

//用户查看近期画作历史记录
  @GET("/users/{userId}/illustHistory")
  Future<Result<List<Illust>>> queryHistoryListInfo(
    @Path("userId") String userId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

//用户查看早期画作历史记录
  @GET("/users/{userId}/oldIllustHistory")
  Future<Result<List<Illust>>> queryOldHistoryListInfo(
    @Path("userId") String userId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

  //获取带有3幅近期画作的关注画师列表
  @GET("/users/{userId}/followedWithRecentlyIllusts")
  Future<Result<List<Artist>>> queryFollowedWithRecentlyIllustsInfo(
      @Path("userId") int userId,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

//收藏画集
  @POST("/users/bookmarked/collections")
  Future<String> queryMarkCollectionInfo(
    @Path("userId") int userId,
    @Body() Map body,
  );

//取消收藏画集
  @DELETE("/users/bookmarked/collections")
  Future<String> queryCancelMarkCollectionInfo(
    @Body() Map body,
  );

//获取收藏画集列表
  @GET("/collections/{collectionId}/illustrations")
  Future<Result<List<Illust>>> queryGetCollectionListInfo(
    @Path("collectionId") int collectionId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

  //点赞画集 类型不定
  @POST("/user/liked/collections")
  Future<String> queryLikeCollectionInfo(
    @Body() int collectionId,
  );

  //取消点赞画集
  @DELETE("/users/liked/collections")
  Future<String> queryCancelLikeCollectionInfo(
    @Body() int collectionId,
  );
}
