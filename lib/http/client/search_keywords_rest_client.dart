import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/search_keywords.dart';
import 'package:pixivic/common/do/result.dart';

part 'search_keywords_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class SearchKeywordsRestClient {
  @factoryMethod
  factory SearchKeywordsRestClient(Dio dio,
      {@Named("baseUrl") String baseUrl}) = _SearchKeywordsRestClient;

  @GET("/keywords/{keyword}/pixivSuggestions")
  Future<Result<List<SearchKeywords>>> queryPixivSuggestionsInfo(
      @Path("keyword") String keyword);
@GET("/keywords/{keyword}/translations")
Future<Result<SearchKeywords>> queryKeyWordsToTranslatedInfo(
    @Path("keyword") String keyword);
}
