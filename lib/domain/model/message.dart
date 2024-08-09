import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain.dart';

part 'message.freezed.dart';

@freezed
class Message with _$Message {
  const factory Message.text({
    required String id,
    required DateTime date,
    required String? text,
    @Default(<Attachment>[]) List<Attachment> images,
  }) = TextMessage;

  const factory Message.audio({
    required String id,
    required DateTime date,
    required String url,
  }) = AudioMessage;

  const factory Message.file({
    required String id,
    required DateTime date,
    required List<Attachment> files,
  }) = FileMessage;
}
