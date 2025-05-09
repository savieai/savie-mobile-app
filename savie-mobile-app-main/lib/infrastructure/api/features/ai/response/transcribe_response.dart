import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcribe_response.freezed.dart';
part 'transcribe_response.g.dart';

@freezed
class TranscribeResponse with _$TranscribeResponse {
  const factory TranscribeResponse({
    required String transcription,
  }) = _TranscribeResponse;

  const TranscribeResponse._();

  factory TranscribeResponse.fromJson(Map<String, Object?> json) =>
      _$TranscribeResponseFromJson(json);
}
