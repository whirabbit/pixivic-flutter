import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/collection.dart';
import 'package:pixivic/common/do/illust.dart';

part 'collection_rest_client.g.dart';

@lazySingleton
@RestApi(baseUrl: "https://pix.ipv4.host")
abstract class CollectionRestClient {
  @factoryMethod
  factory CollectionRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _CollectionRestClient;

//兴建画集
  @POST("/collections")
  Future<Result> queryCreateCollectionInfo(
      @Body() Map body, @Header("authorization") String authorization);

//更新画集
  @PUT("/collections/{collectionId}")
  Future<Result> queryUpdateCollectionInfo(
      @Path("collectionId") int collectionId, @Body() Map body);

//删除画集
  @DELETE("/collections/{collectionId}")
  Future<Result<bool>> queryDeleteCollectionInfo(
      @Path("collectionId") int collectionId);

  //添加画作到画集中
  @POST("/collections/{collectionId}/illustrations")
  Future<Result> queryAddIllustToCollectionInfo(
      @Path("collectionId") int collectionId, @Body() List<int> body);

  //从画集中删除画作 返回类型不定
  @DELETE("/collections/{collectionId}/illustrations/{illustId}")
  Future queryDeleteIllustToCollectionInfo(
      @Path("collectionId") int collectionId, @Path("illustId") List<int> body);

  //排序画集画作(全量)
  @PUT("/collections/{collectionId}/illustrations/order")
  Future<Result<bool>> queryOrderCollectionIllustInfo(
      @Path("collectionId") int collectionId, @Body() List body);

  //查看用户画集
  @GET("/users/{userId}/collections")
  Future<Result<List<Collection>>> queryViewUserCollectionInfo(
    @Path("userId") int userId,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
    // @Query("isPublic") bool isPublic,
  );

  //查看画集下画作列表
  @GET("/collections/{collectoinId}/illustrations")
  Future<Result<List<Illust>>> queryViewCollectionIllustInfo(
      @Path("collectionId") int collectionId,
      @Query("page") int page,
      @Query("pageSize") int pageSize);

  //获取最新公开画集
  @GET("/collections/latest")
  Future<Result<List<Collection>>> queryGetLastPublicCollectionInfo(
      @Query("page") int page, @Query("pageSize") int pageSize);

  //获取最热画集
  @GET("/collections/pop")
  Future<Result<List<Collection>>> queryGetPopCollectionInfo(
      @Query("page") int page, @Query("pageSize") int pageSize);

//标签补全
  @GET("/collections/tags")
  Future<Result<List<TagList>>> queryTagComplementInfo(
      @Query("keyword") String keyword);

  //根据Id查看画集
  @GET("/collections/{collctionId}")
  Future<Result<Collection>> querySearchCollectionByIdInfo(
      @Path("collctionId") int collctionId);

//拖动更新画集内画作顺序 返回类型不定
  @PUT("/collections/{collectionId}/illustrations/orderByDrag")
  Future queryOrderIllustByDragInfo(
      @Path("collectionId") int collectionId, @Body() Map body);

  //用户获取自己的画集摘要列表(用于快速添加)
  @GET("/users/{userId}/collectionsDigest")
  Future<List<CollectionSummary>> queryGetOneselfCollectionSummaryInfo(
      @Path("userId") int userId, @Query("isPublic") bool isPublic);

//修改画集封面 返回类型暂定
  @PUT("/collections/{collectionId}/cover")
  Future queryModifyCollectionCoverInfo(
      @Path("collectionId	") int collectionId, @Body() List<int> body);

//批量删除画作 返回类型不定
  @DELETE("/collections/{collectionId}/illustrations")
  Future queryBulkDeleteCollectionInfo(
      @Path("collectionId") int collectionId, @Body() List<int> body);

  //搜索画集
  @GET("/collections")
  Future querySearchCollectionInfo(
    @Query("keyword") String keyword,
    @Query("page") int page,
    @Query("pageSize") int pageSize,
    @Query("startCreateDate") String startCreateDate,
    @Query("endCreateDate") String endCreateDate,
    @Query("startUpdateDate") String startUpdateDate,
    @Query("endUpdateDate") String endUpdateDate,
  );
}
