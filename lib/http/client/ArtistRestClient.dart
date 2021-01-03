import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/Artist.dart';
import 'package:pixivic/common/do/Result.dart';

part 'ArtistRestClient.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class ArtistRestClient {
  @factoryMethod
  factory ArtistRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _ArtistRestClient;

  @GET("/artists/{artistId}")
  Future<Result<Artist>> queryArtistInfo(@Path() int artistId);
}
