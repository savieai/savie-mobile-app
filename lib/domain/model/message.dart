import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain.dart';
import 'task_extraction_state.dart';

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
    required List<TextContent>? originalTextContents,
    @Default(<Attachment>[]) List<Attachment> images,
    @Default(<Link>[]) List<Link> links,
    @Default(false) bool improvementFailed,
    required List<TextContent>? improvedTextContents,
    @Default(<Task>[]) List<Task> tasks,
    TaskExtractionState? taskExtractionState,
  }) = TextMessage;

  const factory Message.audio({
    required bool isPending,
    @Default(false) bool isNew,
    @Default(false) bool isRemoved,
    required String id,
    required String? tempId,
    required DateTime date,
    required AudioInfo audioInfo,
    required String? transcription,
    @Default(false) bool transcriptionFailed,
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
          return message.originalTextContents == null
              ? AppEventMessageType.image
              : AppEventMessageType.imageWithCaption;
        } else {
          return message.originalTextContents == null
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
  Delta? get originalDeltaContent => originalTextContents == null
      ? null
      : TextContent.toDelta(originalTextContents!);

  String? get originalPlainText => originalDeltaContent == null
      ? null
      : Document.fromDelta(originalDeltaContent!).toPlainText();

  Delta? get improvedDeltaContent => improvedTextContents == null
      ? null
      : TextContent.toDelta(improvedTextContents!);

  String? get improvedPlainText => improvedDeltaContent == null
      ? null
      : Document.fromDelta(improvedDeltaContent!).toPlainText();

  Delta? get currentDeltaContent =>
      improvedDeltaContent ?? originalDeltaContent;

  String? get currentPlainText => improvedPlainText ?? originalPlainText;
}
