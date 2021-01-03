import 'package:json_annotation/json_annotation.dart';
part 'Artist.g.dart';

@JsonSerializable()
class Artist {
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
      this.totalIllustBookmarksPublic});


  @override
  String toString() {
    return 'Artist{id: $id, name: $name, account: $account, avatar: $avatar, comment: $comment, gender: $gender, birthDay: $birthDay, region: $region, webPage: $webPage, twitterAccount: $twitterAccount, twitterUrl: $twitterUrl, totalFollowUsers: $totalFollowUsers, totalIllustBookmarksPublic: $totalIllustBookmarksPublic}';
  }

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
