import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_message_dto.freezed.dart';
part 'voice_message_dto.g.dart';

@freezed
class VoiceMessageDTO with _$VoiceMessageDTO {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory VoiceMessageDTO({
    required String id,
    required String signedUrl,
    required String url,
    required String name,
    required int duration,
    required List<double> peaks,
    required DateTime createdAt,
    required String messageId,
    required String? transcriptionText,
  }) = _VoiceMessageDTO;

  const VoiceMessageDTO._();

  factory VoiceMessageDTO.fromJson(Map<String, Object?> json) =>
      _$VoiceMessageDTOFromJson(json);
}
