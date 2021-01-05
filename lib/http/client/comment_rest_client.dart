import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/comment.dart';


part 'comment_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class CommentRestClient{
  @factoryMethod
  factory CommentRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _CommentRestClient;
  @GET("/{commentAppType}/{commentAppId}/comments")
  Future<Result<List<Comment>>> queryCommentInfo(@Path("commentAppType")String illusts,@Path("commentAppId") int illustId,
      @Query("page") int page, @Query("pageSize") int pageSize);
}
