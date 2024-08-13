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
    required String name,
    required String fullUrl,
  }) = AudioMessage;

  const factory Message.file({
    required String id,
    required DateTime date,
    required List<Attachment> files,
  }) = FileMessage;

  const Message._();

  AppEventMessageType get appEventMessageType {
    return map(
      audio: (_) => AppEventMessageType.voice,
      file: (_) => AppEventMessageType.file,
      text: (TextMessage message) {
        if (message.images.isEmpty) {
          return AppEventMessageType.text;
        } else if (message.images.length == 1) {
          return message.text == null
              ? AppEventMessageType.image
              : AppEventMessageType.imageWithCaption;
        } else {
          return message.text == null
              ? AppEventMessageType.images
              : AppEventMessageType.imagesWithCaption;
        }
      },
    );
  }
}
