import 'package:json_annotation/json_annotation.dart';
import 'package:pixivic/common/do/illust.dart';

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

@JsonSerializable()
class HotSearch {
  String name;
  String translatedName;
  Illust illustration;
  HotSearch({this.name, this.translatedName,this.illustration});

  factory HotSearch.fromJson(Map<String, dynamic> json) =>
      _$HotSearchFromJson(json);

  Map<String, dynamic> toJson() => _$HotSearchToJson(this);
}
