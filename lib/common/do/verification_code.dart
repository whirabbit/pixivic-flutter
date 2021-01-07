import 'package:json_annotation/json_annotation.dart';

part 'verification_code.g.dart';

@JsonSerializable()
class VerificationCode {
  String vid;
  String imageBase64;

  VerificationCode({this.vid, this.imageBase64});

  factory VerificationCode.fromJson(Map<String, dynamic> json) =>
      _$VerificationCodeFromJson(json);

  Map<String, dynamic> toJson() => _$VerificationCodeToJson(this);
}
