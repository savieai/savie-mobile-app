import 'package:freezed_annotation/freezed_annotation.dart';

part 'enhance_request.freezed.dart';
part 'enhance_request.g.dart';

@freezed
class EnhanceRequest with _$EnhanceRequest {
  const factory EnhanceRequest({
    required String content,
  }) = _EnhanceRequest;

  factory EnhanceRequest.fromJson(Map<String, Object?> json) =>
      _$EnhanceRequestFromJson(json);
}
