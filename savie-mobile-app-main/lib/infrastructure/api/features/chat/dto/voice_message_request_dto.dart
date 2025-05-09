import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_message_request_dto.freezed.dart';
part 'voice_message_request_dto.g.dart';

@freezed
class VoiceMessageRequestDTO with _$VoiceMessageRequestDTO {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory VoiceMessageRequestDTO({
    required String url,
    required String name,
    required int duration,
    required String peaks,
  }) = _VoiceMessageRequestDTO;

  const VoiceMessageRequestDTO._();

  factory VoiceMessageRequestDTO.fromJson(Map<String, Object?> json) =>
      _$VoiceMessageRequestDTOFromJson(json);
}
