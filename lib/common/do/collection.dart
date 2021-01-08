import 'package:json_annotation/json_annotation.dart';

part 'collection.g.dart';

@JsonSerializable()
class Collection {
  int id;
  int userId;
  String username;
  List<Cover> cover;
  String title;
  String caption;
  List<TagList> tagList;
  int illustCount;
  var illustrationList;
  int isPublic;
  int useFlag;
  int forbidComment;
  int pornWarning;
  int totalBookmarked;
  int totalView;
  int totalPeopleSeen;
  int totalLiked;
  int totalReward;
  String createTime;

  Collection(
      {this.id,
      this.userId,
      this.username,
      this.cover,
      this.title,
      this.caption,
      this.tagList,
      this.illustCount,
      this.illustrationList,
      this.isPublic,
      this.useFlag,
      this.forbidComment,
      this.pornWarning,
      this.totalBookmarked,
      this.totalView,
      this.totalPeopleSeen,
      this.totalLiked,
      this.totalReward,
      this.createTime});

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);
}

@JsonSerializable()
class Cover {
  String squareMedium;
  String medium;
  String large;
  String original;

  Cover({this.squareMedium, this.medium, this.large, this.original});

  factory Cover.fromJson(Map<String, dynamic> json) => _$CoverFromJson(json);

  Map<String, dynamic> toJson() => _$CoverToJson(this);
}

@JsonSerializable()
class TagList {
  int id;
  String tagName;

  TagList({this.id, this.tagName});

  factory TagList.fromJson(Map<String, dynamic> json) =>
      _$TagListFromJson(json);

  Map<String, dynamic> toJson() => _$TagListToJson(this);
}
@JsonSerializable()
class CollectionSummary {
  int id;
  String title;

  CollectionSummary(this.title, this.id);

  factory CollectionSummary.fromJson(Map<String, dynamic> json) =>
      _$CollectionSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionSummaryToJson(this);
}
