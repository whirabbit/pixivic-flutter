import 'package:json_annotation/json_annotation.dart';

part 'search_keywords.g.dart';

@JsonSerializable()
class SearchKeywords {
  String keyword;
  String keywordTranslated;

  SearchKeywords({this.keyword, this.keywordTranslated});

  factory SearchKeywords.fromJson(Map<String, dynamic> json) =>
      _$SearchKeywordsFromJson(json);

  Map<String, dynamic> toJson() => _$SearchKeywordsToJson(this);
}
