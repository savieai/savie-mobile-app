import 'package:freezed_annotation/freezed_annotation.dart';

part 'enhance_request.freezed.dart';
part 'enhance_request.g.dart';

@freezed
class EnhanceRequest with _$EnhanceRequest {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EnhanceRequest({
    required String content,
    required String? format,
    required String messageId,
  }) = _EnhanceRequest;

  factory EnhanceRequest.fromJson(Map<String, Object?> json) =>
      _$EnhanceRequestFromJson(json);
}
