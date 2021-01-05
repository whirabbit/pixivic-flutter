import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/result.dart';

part 'artist_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class ArtistRestClient {
  @factoryMethod
  factory ArtistRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _ArtistRestClient;

  @GET("/artists/{artistId}")
  Future<Result<Artist>> queryArtistInfo(@Path() int artistId);
}
