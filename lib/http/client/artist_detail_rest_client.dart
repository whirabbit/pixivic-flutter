import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/artist_detail.dart';
import 'package:pixivic/common/do/result.dart';

part 'artist_detail_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class ArtistDetailRestClient {
  @factoryMethod
  factory ArtistDetailRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _ArtistDetailRestClient;

  @GET("/artists/{artistId}")
  Future<Result<ArtistDetail>> queryArtistDetailInfo(@Path() int artistId);
}
