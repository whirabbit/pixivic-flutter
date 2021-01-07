import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/spotlight.dart';
import 'package:pixivic/common/do/result.dart';

part 'spotlight_rest_client.g.dart';

@Injectable()
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class SpotlightRestClient {
  @factoryMethod
  factory SpotlightRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _SpotlightRestClient;

  @GET("/spotlights")
  Future<Result<List<Spotlight>>> querySpotlightListInfo(
      @Query("page") int page, @Query("pageSize") int pageSize);

  @GET("/spotlights/{spotlightId}/illustrations")
  Future<Result<List<Illust>>> querySpotlightIllustListInfo(
      @Path("spotlightId") int spotlightId);
}
