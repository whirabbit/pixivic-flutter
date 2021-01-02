import 'package:json_annotation/json_annotation.dart';

part 'Comment.g.dart';

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
  List<SubComment> subComment;

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
        this.subComment});

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class SubComment {
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
  List subComment;

  SubComment(
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
        this.subComment});

  factory SubComment.fromJson(Map<String, dynamic> json) =>
      _$SubCommentFromJson(json);

  Map<String, dynamic> toJson() => _$SubCommentToJson(this);
}
