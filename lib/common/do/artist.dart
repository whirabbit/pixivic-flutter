

import 'package:json_annotation/json_annotation.dart';

import 'illust.dart';
part 'artist.g.dart';
@JsonSerializable()
//带有三张图片的画师
class Artist {
  int id;
  String name;
  String account;
  String avatar;
  String comment;
  String gender;
  String birthDay;
  String region;
  String webPage;
  String twitterAccount;
  String twitterUrl;
  String totalFollowUsers;
  String totalIllustBookmarksPublic;
  var isFollowed;
  List<Illust> recentlyIllustrations;

  Artist(
      {this.id,
        this.name,
        this.account,
        this.avatar,
        this.comment,
        this.gender,
        this.birthDay,
        this.region,
        this.webPage,
        this.twitterAccount,
        this.twitterUrl,
        this.totalFollowUsers,
        this.totalIllustBookmarksPublic,
        this.isFollowed,
        this.recentlyIllustrations});

 factory Artist.fromJson(Map<String, dynamic> json)=>_$ArtistFromJson(json);
  Map<String, dynamic> toJson()=>_$ArtistToJson(this);
}
// @JsonSerializable()
// class Illust {
//   int id;
//   double artistId;
//   String title;
//   String type;
//   String caption;
//   ArtistPreView artistPreView;
//   List<Tags> tags;
//   List<ImageUrls> imageUrls;
//   List<String> tools;
//   DateTime createDate;
//   int pageCount;
//   double width;
//   double height;
//   double sanityLevel;
//   double restrict;
//   double totalView;
//   double totalBookmarks;
//   bool isLiked;
//   double xrestrict;
//   String link;
//   int adId;
//
//   Illust(
//       {this.id,
//         this.artistId,
//         this.title,
//         this.type,
//         this.caption,
//         this.artistPreView,
//         this.tags,
//         this.imageUrls,
//         this.tools,
//         this.createDate,
//         this.pageCount,
//         this.width,
//         this.height,
//         this.sanityLevel,
//         this.restrict,
//         this.totalView,
//         this.totalBookmarks,
//         this.xrestrict,
//         this.isLiked,this.link,this.adId});
//
//   factory Illust.fromJson(Map<String, dynamic> json)=>_$RecentlyIllustrationsFromJson(json);
//
//
//   Map<String, dynamic> toJson()=>_$RecentlyIllustrationsToJson(this);
// }
@JsonSerializable()
class ArtistPreView {
  int id;
  String name;
  String account;
  String avatar;
  bool isFollowed;

  ArtistPreView(
      {this.id, this.name, this.account, this.avatar, this.isFollowed});

  factory ArtistPreView.fromJson(Map<String, dynamic> json)=>_$ArtistPreViewFromJson(json);


  Map<String, dynamic> toJson()=>_$ArtistPreViewToJson(this);
}
@JsonSerializable()
class Tags {
  String name;
  String translatedName;
  int id;

  Tags({this.name, this.translatedName, this.id});

  factory Tags.fromJson(Map<String, dynamic> json)=>_$TagsFromJson(json);

  Map<String, dynamic> toJson()=>_$TagsToJson(this);
}
@JsonSerializable()
class ImageUrls {
  String squareMedium;
  String medium;
  String large;
  String original;

  ImageUrls({this.squareMedium, this.medium, this.large, this.original});

  factory ImageUrls.fromJson(Map<String, dynamic> json)=>_$ImageUrlsFromJson(json);


  Map<String, dynamic> toJson()=>_$ImageUrlsToJson(this);
}
