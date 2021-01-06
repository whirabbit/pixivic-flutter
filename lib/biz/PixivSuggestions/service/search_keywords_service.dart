import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/search_keywords.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/http/client/search_keywords_rest_client.dart';


@lazySingleton
class SearchKeywordsService {
  final SearchKeywordsRestClient _SearchKeywordsRestClient;

  SearchKeywordsService(this._SearchKeywordsRestClient);

  processData(List data) {
    List<SearchKeywords> searchKeywordsList = [];
    data.map((s) => SearchKeywords.fromJson(s)).forEach((e) {
      searchKeywordsList.add(e);
    });
    return searchKeywordsList;
  }

  Future<Result<List<SearchKeywords>>> querySearchKeywords(String keyword) {
    return _SearchKeywordsRestClient
        .queryPixivSuggestionsInfo(keyword)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }
  Future<Result<SearchKeywords>> queryKeyWordsToTranslated(String keyword) {
    return _SearchKeywordsRestClient
        .queryKeyWordsToTranslatedInfo(keyword)
        .then((value) {
      if (value.data != null) value.data = SearchKeywords.fromJson(value.data);
      return value;
    });
  }
}
