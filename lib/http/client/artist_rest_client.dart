import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:retrofit/retrofit.dart';

part 'artist_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class ArtistRestClient {
  @factoryMethod
  factory ArtistRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _ArtistRestClient;

  @GET("/artists/{artistId}/illusts/{type}")
  Future<Result<List<Illust>>> queryArtistIllustListInfo(
      @Path("artistId") int artistId,
      @Path("type") String type,
      @Query("page") int page,
      @Query("pageSize") int pageSize,
      @Query("maxSanityLevel") int maxSanityLevel);

  @GET("/artists/{artistId}")
  Future<Result<Artist>> querySearchArtistByIdInfo(@Path() int artistId,
  @ReceiveProgress() ProgressCallback onReceiveProgress );

  @GET("/artists/{artistId}/summary")
  Future<Result<ArtistSummary>> queryArtistIllustSummaryInfo(
      @Path("artistId") int artistId);

  // @GET("/artists/{artistId}/followedUsers")

  @GET("/artists")
  Future<Result<List<Artist>>> querySearchArtistInfo(
      @Query("artistName") String artistName,
      @Query("page") int page,
      @Query("pageSize") int pageSize);
}
