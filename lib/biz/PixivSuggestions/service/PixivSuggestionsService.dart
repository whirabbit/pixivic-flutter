import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/PixivSuggestions.dart';
import 'package:pixivic/common/do/Result.dart';
import 'package:pixivic/http/client/PixivSuggestionsRestClient.dart';

@lazySingleton
class PixivSuggestionsService {
  final PixivSuggestionsRestClient _pixivSuggestionsRestClient;

  PixivSuggestionsService(this._pixivSuggestionsRestClient);

  processData(List data) {
    List<PixivSuggestions> PixivSuggestionsList = [];
    data.map((s) => PixivSuggestions.fromJson(s)).forEach((e) {
      PixivSuggestionsList.add(e);
    });
    return PixivSuggestionsList;
  }

  Future<Result<List<PixivSuggestions>>> queryPixivSuggestions(String keyword) {
    return _pixivSuggestionsRestClient
        .queryPixivSuggestionsInfo(keyword)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value;
    });
  }
}
