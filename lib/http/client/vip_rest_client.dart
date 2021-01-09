import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/server_address.dart';
import 'package:pixivic/common/do/user_info.dart';

part 'vip_rest_client.g.dart';

@RestApi(baseUrl: "https://pix.ipv4.host")
@Injectable()
abstract class VIPRestClient {
  @factoryMethod
  factory VIPRestClient(Dio dio, {@Named("baseUrl") String baseUrl}) =
      _VIPRestClient;

  //兑换会员码
  @PUT("/users/{userId}/permissionLevel")
  Future<Result<bool>> queryGetVIPCodeInfo(
    @Path("userId") int userId,
    @Query("exchangeCode") String exchangeCode,
  );

  //获取高速服务器
  @GET("/vipProxyServer")
  Future<Result<ServerAddress>> queryGetHighSpeedServerInfo();

//获取活动可参与状态
  @GET("/vipActivity/{activityName}/canParticipateStatus")
  Future<Result<String>> queryCanParticipateStatusInfo(
      @Path("activityName") String activityName);

  //参与活动
  @PUT("/vipActivity/{activityName}/participateStatus")
  Future<Result<UserInfo>> queryParticipateInfo(
      @Path("activityName") String activityName);
}
