import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/common/do/result.dart';

part 'recommended_rest_client.g.dart';

@Injectable()
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class RecommendedRestClient {
  @factoryMethod
  factory RecommendedRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _RecommendedRestClient;

  @GET("/users/{userId}/recommendBookmarkIllusts")
  Future<Result<List<Illust>>> queryRecommendCollectIllustInfo(
      @Path("userId") int userId);
}
