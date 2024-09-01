part of 'chat_cubit.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required List<Message> messages,
    @Default(<String, Message>{}) Map<String, Message> removedMessages,
  }) = _ChatState;
}
