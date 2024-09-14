part of 'chat_cubit.dart';

@freezed
class ChatItem with _$ChatItem {
  const factory ChatItem.message({
    required Message message,
  }) = MessageChatItem;

  const factory ChatItem.date({
    required DateTime date,
  }) = DateChatItem;

  const ChatItem._();

  String get currentId => when(
        message: (Message m) => m.currentId,
        date: (DateTime date) => date.toIso8601String(),
      );
}

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default(<ChatItem>[]) List<ChatItem> chatItems,
    @Default(false) bool fetchingPrevious,
    @Default(false) bool fetchingNext,
  }) = _ChatState;
}
