import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/comment.dart';

part 'comment_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class CommentRestClient {
  @factoryMethod
  factory CommentRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _CommentRestClient;

  // @POST("/{commentAppType}/{commentAppId}/comments")
  @GET("/{commentAppType}/{commentAppId}/comments")
  Future<Result<List<Comment>>> queryGetCommentInfo(
      @Path("commentAppType") String commentAppType,
      @Path("commentAppId") int illustId,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

  // @POST("/user/likedComments")
  // @DELETE("/user/likedComments/{commentAppType}/{commentAppId}/{commentId}")
  //没有使用
  @GET("/{commentAppType}/{commentAppId}/topCommentCount")
  Future<Result<Comment>> queryGetTopCommentCountInfo(
      @Path("commentAppType") String commentAppType,
      @Path("commentAppId") int commentAppId);

  @GET("/comments/{commentId}")
  Future<Result<Comment>> queryGetSingleCommentInfo(
    @Path("commentId") int commentId,
  );
}
