import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  int id;
  String username;
  String email;
  String avatar;
  var gender;
  var signature;
  var location;
  int permissionLevel;
  int isBan;
  int star;
  bool isCheckEmail;
  String createDate;
  String updateDate;
  var permissionLevelExpireDate;
  bool isBindQQ;

  UserInfo(
      {this.id,
      this.username,
      this.email,
      this.avatar,
      this.gender,
      this.signature,
      this.location,
      this.permissionLevel,
      this.isBan,
      this.star,
      this.isCheckEmail,
      this.createDate,
      this.updateDate,
      this.permissionLevelExpireDate,
      this.isBindQQ});

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
