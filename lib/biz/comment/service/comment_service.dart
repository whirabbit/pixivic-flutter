import 'package:injectable/injectable.dart';

import 'package:pixivic/http/client/comment_rest_client.dart';
import 'package:pixivic/common/do/comment.dart';

@lazySingleton
class CommentService {
  final CommentRestClient _commentRestClient;

  CommentService(this._commentRestClient);

  processData(List data) {
    List<Comment> commentList = data.map((s) => Comment.fromJson(s)).toList();

    return commentList;
  }

  Future<List<Comment>> queryGetComment(
      String commentAppType, int illustId, int page, int pageSize) {
    return _commentRestClient
        .queryGetCommentInfo(commentAppType, illustId, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processData(value.data);
      return value.data as List<Comment>;
    });
  }

  Future<String> querySubmitComment(
      String commentAppType, int illustId, Map body,
      {Function onReceiveProgress}) {
    return _commentRestClient
        .querySubmitCommentInfo(
            commentAppType, illustId, body, onReceiveProgress)
        .then((value) {
      return value;
    });
  }

  Future<String> queryLikedComment(
    Map body,
  ) {
    return _commentRestClient.queryLikedCommentInfo(body).then((value) {
      return value;
    });
  }

  Future<String> queryCancelLikedComment(
      String commentAppType, int commentAppId, int commentId) {
    return _commentRestClient
        .queryCancelLikedCommentInfo(commentAppType, commentAppId, commentId)
        .then((value) {
      return value;
    });
  }
}
