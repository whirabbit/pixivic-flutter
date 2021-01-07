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

  @GET("/illusts/{illustId}")
  Future<Result<Illust>> querySearchIllustByIdInfo(
    @Path("illustId") int illustId,
  );

  @GET("/illusts/{illustId}/related")
  Future<Result<List<Illust>>> queryRelatedIllustListInfo(
      @Path("illustId") num illustId,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

  @GET("/illusts/{illustId}/bookmarkedUsers")
  Future<Result<List<Illust>>> queryUserOfCollectionIllustListInfo(
      @Path("illustId") num illustId,
      @Query("page") int page,
      @Query("pageSize") int pageSize);
}
