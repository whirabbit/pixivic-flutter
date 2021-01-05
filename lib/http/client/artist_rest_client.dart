import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:retrofit/http.dart';

part 'artist_rest_client.g.dart';
@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class ArtistRestClient{
  @factoryMethod
  factory ArtistRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
  _ArtistRestClient;
  @GET("/users/{userId}/followedWithRecentlyIllusts")
  Future<Result<List<Artist>>> queryFollowedWithRecentlyIllusts(@Path("userId")int userId,
      @Query("page") int page, @Query("pageSize") int pageSize);
  @GET("/artists")
  Future<Result<List<Artist>>> querySearch(@Query("artistName") String artistName,
      @Query("page") int page, @Query("pageSize") int pageSize);

}