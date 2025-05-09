import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../infrastructure.dart';

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
    required String? tempId,
    required DateTime createdAt,
    required Map<String, dynamic>? deltaContent,
    required Map<String, dynamic>? enhancedDeltaContent,
    required String userId,
    required List<VoiceMessageDTO>? voiceMessages,
    @Default(<LinkDTO>[]) List<LinkDTO> links,
    required List<FileAttachmentResponseDTO> attachments,
  }) = _MessageDTO;

  const MessageDTO._();

  factory MessageDTO.fromJson(Map<String, Object?> json) =>
      _$MessageDTOFromJson(json);
}
