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
  const factory ChatState.loading() = ChatLoading;

  const factory ChatState.fetched({
    @Default(<ChatItem>[]) List<ChatItem> earlierMessages,
    @Default(<ChatItem>[]) List<ChatItem> laterMessages,
    @Default(<Message>[]) List<Message> pendingMessages,
    @Default(false) bool fetchingPrevious,
    @Default(false) bool fetchingNext,
    @Default(<String>[]) List<String> transcribingAudioMessageIds,
    @Default(<String>[]) List<String> improvingTextMessageIds,
  }) = ChatFetched;
}
