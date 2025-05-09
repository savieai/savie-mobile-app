part of 'message_cubit.dart';

@freezed
class MessageState with _$MessageState {
  const factory MessageState({
    required Message message,
    @Default(false) bool isAudioTranscriptionExpanded,
    @Default(false) bool isImprovedTextExpanded,
  }) = _MessageState;
}
