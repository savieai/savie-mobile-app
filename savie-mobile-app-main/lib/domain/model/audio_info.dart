import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_info.freezed.dart';

@freezed
class AudioInfo with _$AudioInfo {
  const factory AudioInfo({
    required String name,
    required String messageId,
    String? signedUrl,
    String? localFullPath,
    required Duration duration,
    required List<double> peaks,
  }) = _AudioInfo;

  const AudioInfo._();
}
