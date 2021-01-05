import 'package:json_annotation/json_annotation.dart';
part 'artist_detail.g.dart';

@JsonSerializable()
class ArtistDetail {
  double id;
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

  ArtistDetail(
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
      this.totalIllustBookmarksPublic});


  @override
  String toString() {
    return 'ArtistDetail{id: $id, name: $name, account: $account, avatar: $avatar, comment: $comment, gender: $gender, birthDay: $birthDay, region: $region, webPage: $webPage, twitterAccount: $twitterAccount, twitterUrl: $twitterUrl, totalFollowUsers: $totalFollowUsers, totalIllustBookmarksPublic: $totalIllustBookmarksPublic}';
  }

  factory ArtistDetail.fromJson(Map<String, dynamic> json) => _$ArtistDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistDetailToJson(this);
}

@JsonSerializable()
class ArtistSummary {
  int illustSum;
  int mangaSum;

  ArtistSummary({this.illustSum, this.mangaSum});

 factory ArtistSummary.fromJson(Map<String, dynamic> json)=>_$ArtistSummaryFromJson(json);

  Map<String, dynamic> toJson()=>_$ArtistSummaryToJson(this);
}
