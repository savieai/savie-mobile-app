import 'package:freezed_annotation/freezed_annotation.dart';

part 'connect_response.freezed.dart';
part 'connect_response.g.dart';

@freezed
class ConnectResponse with _$ConnectResponse {
  const factory ConnectResponse({
    required String redirectUrl,
  }) = _ConnectResponse;

  const ConnectResponse._();

  factory ConnectResponse.fromJson(Map<String, Object?> json) =>
      _$ConnectResponseFromJson(json);
}
