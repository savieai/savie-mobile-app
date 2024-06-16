import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_message.freezed.dart';

@freezed
class AudioMessage with _$AudioMessage {
  const factory AudioMessage({
    required List<double> peeks,
    required String path,
    required int seconds,
  }) = _AudioMessage;
}
