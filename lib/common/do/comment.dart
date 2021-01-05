import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  int id;
  String appType;
  int appId;
  int parentId;
  int replyFrom;
  String replyFromName;
  int replyTo;
  String replyToName;
  String platform;
  String content;
  String createDate;
  int likedCount;
  bool isLike;
  List<Comment> subCommentList;

  Comment(
      {this.id,
      this.appType,
      this.appId,
      this.parentId,
      this.replyFrom,
      this.replyFromName,
      this.replyTo,
      this.replyToName,
      this.platform,
      this.content,
      this.createDate,
      this.likedCount,
      this.isLike,
      this.subCommentList});

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
