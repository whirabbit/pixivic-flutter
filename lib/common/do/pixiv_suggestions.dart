import 'package:json_annotation/json_annotation.dart';

part 'pixiv_suggestions.g.dart';

@JsonSerializable()
class PixivSuggestions {
  String keyword;
  String keywordTranslated;

  PixivSuggestions({this.keyword, this.keywordTranslated});

  factory PixivSuggestions.fromJson(Map<String, dynamic> json) =>
      _$PixivSuggestionsFromJson(json);

  Map<String, dynamic> toJson() => _$PixivSuggestionsToJson(this);
}
