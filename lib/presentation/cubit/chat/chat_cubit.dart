import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:uuid/uuid.dart';

import '../../../application/application.dart';
import '../../../domain/domain.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

@Injectable()
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._createMessageUseCase,
    this._getMessageUseCase,
    this._createPdfThumbnailUseCase,
    this._deleteMessagesUseCase,
  ) : super(const ChatState()) {
    _fetchMessages(page: _currentPage);
  }

  final CreateMessageUseCase _createMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final CreatePdfThumbnailUseCase _createPdfThumbnailUseCase;
  final DeleteMessagesUseCase _deleteMessagesUseCase;

  static const int _pageSize = 100;
  int _currentPage = 1;

  final Map<String, Message> _pendingMessages = <String, Message>{};

  final SortedMap<String, Message> _sentMessages =
      SortedMap<String, Message>(const Ordering.byValue());

  Future<void> _fetchMessages({
    required int page,
  }) async {
    final List<Message> sentMessages = await _getMessageUseCase.execute(
      pageSize: _pageSize,
      page: page,
    );

    for (final Message m in sentMessages) {
      _sentMessages[m.currentId] = m;
    }

    _pendingMessages.removeWhere(
      (String id, _) => _sentMessages.containsKey(id),
    );

    emit(ChatState(
      chatItems: _getChatItems(
        <Message>[
          ..._sentMessages.values,
          if (_pendingMessages.isNotEmpty) ...<Message>[
            ..._pendingMessages.values.take(_pendingMessages.length - 1),
            _pendingMessages.values.last.copyWith(isNew: true),
          ],
        ],
      ),
    ));
  }

  Future<void> fetchPrevious() async {
    if (_currentPage != 1) {
      _currentPage--;
    }

    emit(state.copyWith(fetchingPrevious: true));
    await _fetchMessages(page: _currentPage);
    emit(state.copyWith(fetchingPrevious: false));
  }

  Future<void> fetchNext() async {
    _currentPage++;

    emit(state.copyWith(fetchingNext: true));
    await _fetchMessages(page: _currentPage);
    emit(state.copyWith(fetchingNext: false));
  }

  Future<void> sendMessage({
    String? text,
    List<String>? mediaPaths,
    bool hasFadeAnimation = false,
  }) async {
    final String pendingUuid = const Uuid().v4();
    final Message message = TextMessage(
      isPending: true,
      tempId: pendingUuid,
      id: pendingUuid,
      date: DateTime.now(),
      text: text,
      images: (mediaPaths ?? <String>[]).map(
        (String mediaPath) {
          final String ext = mediaPath.split('.').last;
          final String remoteStorageName = '${const Uuid().v4()}.$ext';

          return Attachment(
            signedUrl: null,
            name: remoteStorageName,
            remoteStorageName: remoteStorageName,
            localFullPath: mediaPath,
          );
        },
      ).toList(),
    );

    _pendingMessages[pendingUuid] = message;
    emit(ChatState(
      chatItems: _getChatItems(
        <Message>[
          ..._sentMessages.values,
          if (_pendingMessages.isNotEmpty) ...<Message>[
            ..._pendingMessages.values.take(_pendingMessages.length - 1),
            _pendingMessages.values.last.copyWith(isNew: true),
          ],
        ],
      ),
    ));

    await _createMessageUseCase.execute(message);
    _fetchMessages(page: 1);
  }

  Future<void> sendAudio(AudioInfo? audioInfo) async {
    if (audioInfo == null) {
      return;
    }

    final String pendingUuid = const Uuid().v4();

    final Message message = AudioMessage(
      isPending: true,
      id: pendingUuid,
      tempId: pendingUuid,
      date: DateTime.now(),
      audioInfo: AudioInfo(
        messageId: pendingUuid,
        name: audioInfo.name,
        signedUrl: null,
        localFullPath: audioInfo.localFullPath,
        duration: audioInfo.duration,
        peaks: audioInfo.peaks,
      ),
    );

    _pendingMessages[pendingUuid] = message;
    emit(ChatState(
      chatItems: _getChatItems(
        <Message>[
          ..._sentMessages.values,
          if (_pendingMessages.isNotEmpty) ...<Message>[
            ..._pendingMessages.values.take(_pendingMessages.length - 1),
            _pendingMessages.values.last.copyWith(isNew: true),
          ],
        ],
      ),
    ));

    await _createMessageUseCase.execute(message);
    _fetchMessages(page: 1);
  }

  Future<void> sendFile(String? filePath) async {
    if (filePath == null) {
      return;
    }

    final String pendingUuid = const Uuid().v4();
    final String fileName = filePath.split('/').last;
    final String ext = filePath.split('.').last;

    final Attachment file = Attachment(
      signedUrl: null,
      name: fileName,
      remoteStorageName: '${const Uuid().v4()}.$ext',
      localFullPath: filePath,
    );

    final Message message = FileMessage(
      isPending: true,
      id: pendingUuid,
      tempId: pendingUuid,
      date: DateTime.now(),
      file: file,
    );

    if (file.fileType == FileType.pdf) {
      await _createPdfThumbnailUseCase.execute(file);
    }

    _pendingMessages[pendingUuid] = message;
    emit(ChatState(
      chatItems: _getChatItems(
        <Message>[
          ..._sentMessages.values,
          if (_pendingMessages.isNotEmpty) ...<Message>[
            ..._pendingMessages.values.take(_pendingMessages.length - 1),
            _pendingMessages.values.last.copyWith(isNew: true),
          ],
        ],
      ),
    ));

    await _createMessageUseCase.execute(message);
    _fetchMessages(page: 1);
  }

  Future<void> deleteMessage({required String messageId}) async {
    // Create a mutable copy of the current chatItems
    final List<ChatItem> chatItems = List<ChatItem>.from(state.chatItems);
    final List<ChatItem> removedChatItems = <ChatItem>[];

    // Find the index of the message ChatItem to remove
    final int messageIndex = chatItems.indexWhere((ChatItem item) {
      return item.maybeWhen(
        message: (Message m) => m.id == messageId,
        orElse: () => false,
      );
    });

    if (messageIndex == -1) {
      // Message not found, nothing to remove
      return;
    }

    // Remove the message ChatItem from the list
    final ChatItem removedMessageItem = chatItems.removeAt(messageIndex);
    removedChatItems.add(removedMessageItem);

    // Remove the message from _sentMessages
    _sentMessages.removeWhere((_, Message m) => m.id == messageId);

    // Get the date of the removed message
    final DateTime removedMessageDate =
        (removedMessageItem as MessageChatItem).message.date.toDate;

    // Check if there are any messages left on that date
    final bool hasMessagesOnDate = chatItems.any((ChatItem item) {
      return item.maybeWhen(
        message: (Message m) {
          final DateTime messageDate = m.date.toDate;
          return messageDate == removedMessageDate;
        },
        orElse: () => false,
      );
    });

    if (!hasMessagesOnDate) {
      // No messages left on this date, remove the DateChatItem
      final int dateItemIndex = chatItems.indexWhere((ChatItem item) {
        return item.maybeWhen(
          date: (DateTime date) => date == removedMessageDate,
          orElse: () => false,
        );
      });

      if (dateItemIndex != -1) {
        final ChatItem removedDateItem = chatItems.removeAt(dateItemIndex);
        removedChatItems.add(removedDateItem);
      }
    }

    // Emit the new state with updated chatItems and removedChatItems
    emit(state.copyWith(chatItems: chatItems));

    // Perform the deletion operation
    await _deleteMessagesUseCase.execute(messageId: messageId);
  }

  List<ChatItem> _getChatItems(final List<Message> messages) {
    final List<ChatItem> chatItems = <ChatItem>[];
    DateTime? lastDate;

    for (final Message message in messages) {
      // Extract the date part (year, month, day) of the message date
      final DateTime messageDate = message.date.toDate;

      // Check if the date has changed
      if (lastDate == null || messageDate != lastDate) {
        // Insert a DateChatItem for the new date
        chatItems.add(ChatItem.date(date: messageDate));
        lastDate = messageDate;
      }

      // Insert the MessageChatItem
      chatItems.add(ChatItem.message(message: message));
    }

    return chatItems;
  }
}
