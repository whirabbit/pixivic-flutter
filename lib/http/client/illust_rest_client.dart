import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/result.dart';

part 'illust_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class IllustRestClient {
  @factoryMethod
  factory IllustRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _IllustRestClient;

  @GET("/ranks")
  Future<Result<List<Illust>>> queryRank(
      @Query("date") String date,
      @Query("mode") String mode,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

  @GET("/illusts/{illustId}/related")
  Future<Result<List<Illust>>> queryRelated(@Path("illustId") num illustId,
      @Query("page") int page, @Query("pageSize") int pageSize);

  @GET("/illustrations")
  Future<Result<List<Illust>>> querySearch(@Query("page") int page,
      @Query("keyword") String keyword, @Query("pageSize") int pageSize);

  @GET("/artists/{artistId}/illusts/{type}")
  Future<Result<List<Illust>>> queryArtist(
      @Path("artistId") String artistId,
      @Path("type") String type,
      @Query("page") int page,
      @Query("pageSize") int pageSize,
      @Query("maxSanityLevel") int maxSanityLevel);

  @GET("/users/{userId}/followed/latest/{type}")
  Future<Result<List<Illust>>> queryFollowed(
    @Path("userId") String userId,
    @Path("type") String type,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

  @GET("/users/{userId}/bookmarked/{type}")
  Future<Result<List<Illust>>> queryBookmark(
    @Path("userId") String userId,
    @Path("type") String type,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

  @GET("/spotlights/{spotlightId}/illustrations")
  Future<Result<List<Illust>>> querySpotlight(
      @Path("spotlightId") String userId);

  @GET("/users/{userId}/illustHistory")
  Future<Result<List<Illust>>> queryHistory(
    @Path("userId") String userId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

  @GET("/users/{userId}/oldIllustHistory")
  Future<Result<List<Illust>>> queryOldHistory(
    @Path("userId") String userId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );

  @GET("/collections/{collectionId}/illustrations")
  Future<Result<List<Illust>>> queryCollection(
    @Path("collectionId") String collectionId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
  );
}
