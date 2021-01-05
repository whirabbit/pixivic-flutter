import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/pixiv_suggestions.dart';
import 'package:pixivic/common/do/result.dart';

part 'pixiv_suggestions_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class PixivSuggestionsRestClient {
  @factoryMethod
  factory PixivSuggestionsRestClient(Dio dio,
      {@Named("baseUrl") String baseUrl}) = _PixivSuggestionsRestClient;

  @GET("/keywords/{keyword}/pixivSuggestions")
  Future<Result<List<PixivSuggestions>>> queryPixivSuggestionsInfo(
      @Path("keyword") String keyword);
}
