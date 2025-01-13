import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain.dart';

part 'message.freezed.dart';

@freezed
class Message with _$Message implements Comparable<Message> {
  const factory Message.text({
    required bool isPending,
    @Default(false) bool isNew,
    @Default(false) bool isRemoved,
    required String id,
    required String? tempId,
    required DateTime date,
    required List<TextContent>? textContents,
    @Default(<Attachment>[]) List<Attachment> images,
    @Default(<Link>[]) List<Link> links,
  }) = TextMessage;

  const factory Message.audio({
    required bool isPending,
    @Default(false) bool isNew,
    @Default(false) bool isRemoved,
    required String id,
    required String? tempId,
    required DateTime date,
    required AudioInfo audioInfo,
  }) = AudioMessage;

  const factory Message.file({
    required bool isPending,
    @Default(false) bool isNew,
    @Default(false) bool isRemoved,
    required String id,
    required String? tempId,
    required DateTime date,
    required Attachment file,
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
          return message.textContents == null
              ? AppEventMessageType.image
              : AppEventMessageType.imageWithCaption;
        } else {
          return message.textContents == null
              ? AppEventMessageType.images
              : AppEventMessageType.imagesWithCaption;
        }
      },
    );
  }

  String get currentId => tempId ?? id;

  @override
  int compareTo(Message other) => date.compareTo(other.date);
}

extension TextMessageX on TextMessage {
  Delta? get deltaContent =>
      textContents == null ? null : TextContent.toDelta(textContents!);

  String? get plainText => deltaContent == null
      ? null
      : Document.fromDelta(deltaContent!).toPlainText();
}
