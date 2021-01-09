import 'package:json_annotation/json_annotation.dart';
part 'server_address.g.dart';
@JsonSerializable()
class ServerAddress {
  String serverAddress;
ServerAddress({this.serverAddress});
  factory ServerAddress.fromJson(Map<String, dynamic> json) =>
      _$ServerAddressFromJson(json);

  Map<String, dynamic> toJson() => _$ServerAddressToJson(this);
}
