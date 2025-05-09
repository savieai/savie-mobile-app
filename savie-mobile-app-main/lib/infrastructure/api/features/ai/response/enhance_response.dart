import 'package:freezed_annotation/freezed_annotation.dart';

part 'enhance_response.freezed.dart';
part 'enhance_response.g.dart';

@freezed
class EnhanceResponse with _$EnhanceResponse {
  const factory EnhanceResponse({
    required Map<String, dynamic> enhanced,
  }) = _EnhanceResponse;

  const EnhanceResponse._();

  factory EnhanceResponse.fromJson(Map<String, Object?> json) =>
      _$EnhanceResponseFromJson(json);
}
