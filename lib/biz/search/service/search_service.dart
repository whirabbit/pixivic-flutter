import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/search_keywords.dart';
import 'package:pixivic/http/client/search_rest_client.dart';

@lazySingleton
class SearchService {
  final SearchRestClient _searchRestClient;

  SearchService(this._searchRestClient);

  processData(List data) {
    List<SearchKeywords> searchKeywordsList = [];
    data.map((s) => SearchKeywords.fromJson(s)).forEach((e) {
      searchKeywordsList.add(e);
    });
    return searchKeywordsList;
  }

//搜索建议
  Future<Result<List<SearchKeywords>>> querySearchSuggestions(
    String keyword,
  ) {
    return _searchRestClient.querySearchSuggestionsInfo(keyword).then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<List<SearchKeywords>>> queryPixivSearchSuggestions(
    String keyword,
  ) {
    return _searchRestClient
        .queryPixivSearchSuggestionsInfo(keyword)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }

  Future<Result<SearchKeywords>> queryKeyWordsToTranslatedResult(
    String keyword,
  ) {
    return _searchRestClient
        .queryKeyWordsToTranslatedResultInfo(keyword)
        .then((value) {
      if (value.data != null) value.data = SearchKeywords.fromJson(value.data);
      return value;
    });
  }

//类型不定 不可用
  Future<Result<List<SearchKeywords>>> queryHotSearchTags(
    String date,
  ) {
    return _searchRestClient.queryHotSearchTagsInfo(date).then((value) {
      if (value.data != null) value.data = SearchKeywords.fromJson(value.data);
      return value;
    });
  }
}
