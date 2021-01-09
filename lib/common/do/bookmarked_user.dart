import 'package:json_annotation/json_annotation.dart';
part 'bookmarked_user.g.dart';
@JsonSerializable()
class BookmarkedUser{
  String username;
  int userId;
  String createDate;

  BookmarkedUser({this.username, this.userId, this.createDate});

 factory BookmarkedUser.fromJson(Map<String, dynamic> json)=>_$BookmarkedUserFromJson(json);

  Map<String, dynamic> toJson()=>_$BookmarkedUserToJson(this);
}