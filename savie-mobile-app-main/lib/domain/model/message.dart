import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain.dart';
import 'task_extraction_state.dart';
import '../../infrastructure/mapper/message_mapper.dart';

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

  Delta get content {
    Delta delta;
    
    if (this is TextMessage) {
      final textMessage = this as TextMessage;
      if (textMessage.currentTextContents != null) {
        delta = TextContent.toDelta(textMessage.currentTextContents!);
      } else {
        delta = Delta()..insert('\n');
      }
    } else {
      delta = Delta()..insert('\n');
    }
    
    return MessageMapper.fixDeltaFormatting(delta);
  }
}

extension TextMessageX on TextMessage {
  Delta? get originalDeltaContent {
    switch (textEditingTarget) {
      case TextEditingTarget.original:
        return originalTextContents != null
            ? TextContent.toDelta(originalTextContents!)
            : null;
      case TextEditingTarget.enhanced:
        return null;
    }
  }

  String? get originalPlainText {
    switch (textEditingTarget) {
      case TextEditingTarget.original:
        return originalDeltaContent != null
            ? Document.fromDelta(originalDeltaContent!).toPlainText()
            : null;
      case TextEditingTarget.enhanced:
        return null;
    }
  }

  Delta? get improvedDeltaContent {
    switch (textEditingTarget) {
      case TextEditingTarget.enhanced:
        return improvedTextContents != null
            ? TextContent.toDelta(improvedTextContents!)
            : null;
      case TextEditingTarget.original:
        return null;
    }
  }

  String? get improvedPlainText {
    switch (textEditingTarget) {
      case TextEditingTarget.enhanced:
        return improvedDeltaContent != null
            ? Document.fromDelta(improvedDeltaContent!).toPlainText()
            : null;
      case TextEditingTarget.original:
        return null;
    }
  }

  Delta? get currentDeltaContent {
    switch (textEditingTarget) {
      case TextEditingTarget.enhanced:
        return improvedDeltaContent;
      case TextEditingTarget.original:
        return originalDeltaContent;
    }
  }

  String? get currentPlainText {
    switch (textEditingTarget) {
      case TextEditingTarget.enhanced:
        return improvedPlainText;
      case TextEditingTarget.original:
        return originalPlainText;
    }
  }

  List<TextContent>? get currentTextContents {
    switch (textEditingTarget) {
      case TextEditingTarget.enhanced:
        return improvedTextContents;
      case TextEditingTarget.original:
        return originalTextContents;
    }
  }

  TextEditingTarget get textEditingTarget => improvedTextContents != null
      ? TextEditingTarget.enhanced
      : TextEditingTarget.original;
}
