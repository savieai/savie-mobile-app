import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../infrastructure.dart';

part 'create_message_request.freezed.dart';
part 'create_message_request.g.dart';

@freezed
class CreateMessageRequest with _$CreateMessageRequest {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
    includeIfNull: false,
  )
  const factory CreateMessageRequest({
    required String tempId,
    required List<FileAttachmentRequestDTO>? fileAttachments,
    required List<FileAttachmentRequestDTO>? images,
    required String? textContent,
    required VoiceMessageRequestDTO? voiceMessage,
    required String? placeholderUrl,
  }) = _CreateMessageRequest;

  factory CreateMessageRequest.fromJson(Map<String, Object?> json) =>
      _$CreateMessageRequestFromJson(json);
}
