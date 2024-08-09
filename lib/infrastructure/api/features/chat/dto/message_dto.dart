import 'package:freezed_annotation/freezed_annotation.dart';

import 'file_attachment_dto.dart';

part 'message_dto.freezed.dart';
part 'message_dto.g.dart';

@freezed
class MessageDTO with _$MessageDTO {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
  )
  const factory MessageDTO({
    required String id,
    required DateTime createdAt,
    required String? textContent,
    required String userId,
    required String? voiceMessageUrl,
    @Default(<String>[]) List<String> links,
    required List<FileAttachmentDTO> attachments,
  }) = _MessageDTO;

  factory MessageDTO.fromJson(Map<String, Object?> json) =>
      _$MessageDTOFromJson(json);
}
