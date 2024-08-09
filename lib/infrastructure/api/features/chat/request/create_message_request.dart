import 'package:freezed_annotation/freezed_annotation.dart';

import '../dto/file_attachment_dto.dart';

part 'create_message_request.freezed.dart';
part 'create_message_request.g.dart';

@freezed
class CreateMessageRequest with _$CreateMessageRequest {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
  )
  const factory CreateMessageRequest({
    required List<FileAttachmentDTO> fileAttachments,
    required List<FileAttachmentDTO> images,
    required String? textContent,
    required String? voiceMessageUrl,
  }) = _CreateMessageRequest;

  factory CreateMessageRequest.fromJson(Map<String, Object?> json) =>
      _$CreateMessageRequestFromJson(json);
}
