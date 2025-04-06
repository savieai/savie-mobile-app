import 'package:freezed_annotation/freezed_annotation.dart';

part 'enhance_response.freezed.dart';
part 'enhance_response.g.dart';

@freezed
class EnhanceResponse with _$EnhanceResponse {
  const factory EnhanceResponse({
    required String enhanced,
    required String original,
  }) = _EnhanceResponse;

  factory EnhanceResponse.fromJson(Map<String, Object?> json) =>
      _$EnhanceResponseFromJson(json);
}
