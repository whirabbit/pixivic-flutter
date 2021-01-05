import 'package:json_annotation/json_annotation.dart';

part 'illust.g.dart';

@JsonSerializable()
class Illust {
  int id;
  double artistId;
  String title;
  String type;
  String caption;
  ArtistPreView artistPreView;
  List<Tags> tags;
  List<ImageUrls> imageUrls;
  List<String> tools;
  DateTime createDate;
  int pageCount;
  double width;
  double height;
  double sanityLevel;
  double restrict;
  double totalView;
  double totalBookmarks;
  bool isLiked;
  double xrestrict;
  String link;
  int adId;

  @override
  String toString() {
    return 'Illust{id: $id, artistId: $artistId, title: $title, type: $type, caption: $caption, artistPreView: $artistPreView, tags: $tags, imageUrls: $imageUrls, tools: $tools, createDate: $createDate, pageCount: $pageCount, width: $width, height: $height, sanityLevel: $sanityLevel, restrict: $restrict, totalView: $totalView, totalBookmarks: $totalBookmarks, xrestrict: $xrestrict}';
  }

  Illust(
      {this.id,
      this.artistId,
      this.title,
      this.type,
      this.caption,
      this.artistPreView,
      this.tags,
      this.imageUrls,
      this.tools,
      this.createDate,
      this.pageCount,
      this.width,
      this.height,
      this.sanityLevel,
      this.restrict,
      this.totalView,
      this.totalBookmarks,
      this.isLiked,
      this.xrestrict,
      this.adId,
      this.link});

  factory Illust.fromJson(Map<String, dynamic> json) => _$IllustFromJson(json);

  Map<String, dynamic> toJson() => _$IllustToJson(this);
}

@JsonSerializable()
class ArtistPreView {
  int id;
  String name;
  String account;
  String avatar;
  bool isFollowed;

  ArtistPreView(
      {this.id, this.name, this.account, this.avatar, this.isFollowed});

  factory ArtistPreView.fromJson(Map<String, dynamic> json) =>
      _$ArtistPreViewFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistPreViewToJson(this);
}

@JsonSerializable()
class Tags {
  int id;
  String name;
  String translatedName;

  Tags({this.id, this.name, this.translatedName});

  factory Tags.fromJson(Map<String, dynamic> json) => _$TagsFromJson(json);

  Map<String, dynamic> toJson() => _$TagsToJson(this);
}

@JsonSerializable()
class ImageUrls {
  String squareMedium;
  String medium;
  String large;
  String original;

  ImageUrls({this.squareMedium, this.medium, this.large, this.original});

  factory ImageUrls.fromJson(Map<String, dynamic> json) =>
      _$ImageUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUrlsToJson(this);
}
