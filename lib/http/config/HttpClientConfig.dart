import 'package:injectable/injectable.dart';
import 'package:pixivic/function/dio_client.dart';
import 'package:dio/dio.dart';

@module
abstract class HttpClientConfig {
  @Named("baseUrl")
  String get baseUrl => "https://pix.ipv4.host";
  @lazySingleton
  Dio get dio =>dioPixivic;

}