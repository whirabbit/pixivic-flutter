import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/search_keywords.dart';
import 'package:pixivic/http/client/search_rest_client.dart';

@lazySingleton
class SearchService {
  final SearchRestClient _searchRestClient;

  SearchService(this._searchRestClient);

  processData(List data) {
    List<SearchKeywords> searchKeywordsList =
        data.map((s) => SearchKeywords.fromJson(s)).toList();
    return searchKeywordsList;
  }

//搜索建议
  Future<List<SearchKeywords>> querySearchSuggestions(
    String keyword,
  ) {
    return _searchRestClient.querySearchSuggestionsInfo(keyword).then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value.data;
    });
  }

  Future<List<SearchKeywords>> queryPixivSearchSuggestions(
    String keyword,
  ) {
    return _searchRestClient
        .queryPixivSearchSuggestionsInfo(keyword)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value.data;
    });
  }

  Future<SearchKeywords> queryKeyWordsToTranslatedResult(
    String keyword,
  ) {
    return _searchRestClient
        .queryKeyWordsToTranslatedResultInfo(keyword)
        .then((value) {
      if (value.data != null) value.data = SearchKeywords.fromJson(value.data);
      return value.data;
    });
  }

//类型不定 不可用
  Future<List<SearchKeywords>> queryHotSearchTags(
    String date,
  ) {
    return _searchRestClient.queryHotSearchTagsInfo(date).then((value) {
      if (value.data != null) value.data = SearchKeywords.fromJson(value.data);
      return value.data;
    });
  }
}
