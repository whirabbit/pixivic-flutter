import 'package:json_annotation/json_annotation.dart';

part 'spotlight.g.dart';

@JsonSerializable()
class Spotlight {
  int id;
  String title;
  String pureTitle;
  String thumbnail;
  String articleUrl;
  String publishDate;
  String category;
  String subcategoryLabel;

  Spotlight(
      {this.id,
      this.title,
      this.pureTitle,
      this.thumbnail,
      this.articleUrl,
      this.publishDate,
      this.category,
      this.subcategoryLabel});

  factory Spotlight.fromJson(Map<String, dynamic> json) =>
      _$SpotlightFromJson(json);

  Map<String, dynamic> toJson() => _$SpotlightToJson(this);
}
