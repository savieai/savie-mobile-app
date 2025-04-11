import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:sortedmap/sortedmap.dart';
import 'package:uuid/uuid.dart';

import '../../../application/application.dart';
import '../../../domain/domain.dart';
import '../../../domain/model/task_extraction_state.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

@Injectable()
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._createMessageUseCase,
    this._searchInMessagesUseCase,
    this._getMessageUseCase,
    this._createPdfThumbnailUseCase,
    this._createImageThumbnailUseCase,
    this._deleteMessagesUseCase,
    this._findMessageUseCase,
    this._editTextMessageUseCase,
    this._pasteImageUseCase,
    this._processSharingIntent,
    this._processSharingIntentStream,
    this._transcribeAudioMessageUseCase,
    this._improveTextUseCase,
    // this._extractTasksUseCase,
    this._undoTextImprovementUseCase, {
    @factoryParam String? query,
    @factoryParam required bool processSharingIntent,
  })  : _query = query,
        super(const ChatState.loading()) {
    _fetchMessages(1, query: query);

    if (processSharingIntent) {
      _processSharingIntent.execute(this);
      _processSharingIntentSubscription =
          _processSharingIntentStream.execute(this);
    }
  }

  final CreateMessageUseCase _createMessageUseCase;
  final SearchInMessagesUseCase _searchInMessagesUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final CreatePdfThumbnailUseCase _createPdfThumbnailUseCase;
  final CreateImageThumbnailUseCase _createImageThumbnailUseCase;
  final DeleteMessagesUseCase _deleteMessagesUseCase;
  final FindMessageUseCase _findMessageUseCase;
  final EditTextMessageUseCase _editTextMessageUseCase;
  final PasteImageUseCase _pasteImageUseCase;
  final TranscribeAudioMessageUseCase _transcribeAudioMessageUseCase;
  final ImproveTextUseCase _improveTextUseCase;
  // final ExtractTasksUseCase _extractTasksUseCase;
  final UndoTextImprovementUseCase _undoTextImprovementUseCase;

  final ProcessSharingIntentStream _processSharingIntentStream;
  final ProcessSharingIntent _processSharingIntent;

  StreamSubscription<void>? _processSharingIntentSubscription;

  static const int _pageSize = 100;

  int _minimumDisplayedPage = 1;
  int _maximumDisplayedPage = 1;
  int _maximumPage = 2;

  String? _query;

  final SortedMap<String, Message> _sentMessages =
      SortedMap<String, Message>(const Ordering.byValue());

  final Map<String, Message> _pendingMessages = <String, Message>{};

  Message? foundMessage;
  TextMessage? get lastTextMessage => state.map(
        loading: (_) => null,
        fetched: (_) =>
            _sentMessages.values.whereType<TextMessage>().lastOrNull,
      );

  Future<void> _fetchMessages(int page, {required String? query}) async {
    final (Pagination pagination, List<Message> sentMessages) = query == null
        ? await _getMessageUseCase.execute(
            pageSize: _pageSize,
            page: page,
          )
        : await _searchInMessagesUseCase.execute(
            page: page,
            pageSize: _pageSize,
            query: query,
          );

    _maximumPage = pagination.totalPages;

    for (final Message m in sentMessages) {
      _pendingMessages.remove(m.tempId);
      _sentMessages[m.currentId] = m;
    }

    _emitMessages();
  }

  Future<void> fetchLaterMessages() async {
    state.mapOrNull(
      fetched: (ChatFetched _) async {
        if (_minimumDisplayedPage > 1) {
          _minimumDisplayedPage--;
        } else {
          return;
        }

        state.mapOrNull(
          fetched: (ChatFetched f) => emit(f.copyWith(fetchingPrevious: true)),
        );
        await _fetchMessages(_minimumDisplayedPage, query: _query);
        state.mapOrNull(
          fetched: (ChatFetched f) => emit(f.copyWith(fetchingPrevious: false)),
        );
      },
    );
  }

  Future<void> fetchEarlierMessages() async {
    state.mapOrNull(
      fetched: (ChatFetched _) async {
        if (_maximumDisplayedPage < _maximumPage) {
          _maximumDisplayedPage++;
        } else {
          return;
        }

        state.mapOrNull(
          fetched: (ChatFetched f) => emit(f.copyWith(fetchingNext: true)),
        );
        await _fetchMessages(_maximumDisplayedPage, query: _query);
        state.mapOrNull(
          fetched: (ChatFetched f) => emit(f.copyWith(fetchingNext: false)),
        );
      },
    );
  }

  Future<void> findMessages(String query) async {
    _query = query;
    state.mapOrNull(
      fetched: (ChatFetched _) async {
        emit(const ChatState.loading());

        _sentMessages.clear();

        _minimumDisplayedPage = 1;
        _maximumDisplayedPage = 1;
        _maximumPage = 2;

        _fetchMessages(1, query: query);
      },
    );
  }

  Future<void> findMessage(String messageId) async {
    state.mapOrNull(
      fetched: (ChatFetched _) async {
        emit(const ChatState.loading());
        final Pagination pagination = await _findMessage(messageId);
        _minimumDisplayedPage = pagination.currentPage;
        _maximumDisplayedPage = pagination.currentPage;

        await fetchLaterMessages();
      },
    );
  }

  Future<Pagination> _findMessage(String messageId) async {
    final (Pagination pagination, List<Message> messages) =
        await _findMessageUseCase.execute(
      pageSize: _pageSize,
      messageId: messageId,
    );

    _sentMessages.clear();

    for (final Message m in messages) {
      _pendingMessages.remove(m.tempId);
      _sentMessages[m.currentId] = m;
    }

    // Find the index of the message with the given messageId
    final int messageIndex =
        messages.indexWhere((Message message) => message.id == messageId);

    foundMessage = messages[messageIndex];

    _emitMessages();

    return pagination;
  }

  void _emitMessages() {
    if (isClosed) {
      return;
    }

    final List<Message> messagesToEmit = <Message>[
      ..._sentMessages.values,
      if (_pendingMessages.isNotEmpty) ...<Message>[
        ..._pendingMessages.values.take(_pendingMessages.length - 1),
        _pendingMessages.values.last.copyWith(isNew: true),
      ],
    ];

    if (foundMessage == null) {
      emit(ChatState.fetched(
        earlierMessages: _getChatItems(messagesToEmit),
      ));
    } else {
      final Iterable<Message> earlierMessages = messagesToEmit.where(
        (Message message) => !message.date.isAfter(foundMessage!.date),
      );
      final Iterable<Message> laterMessages = messagesToEmit.where(
        (Message message) => message.date.isAfter(foundMessage!.date),
      );

      emit(ChatState.fetched(
        earlierMessages: _getChatItems(earlierMessages.toList()),
        laterMessages: _getChatItems(
          laterMessages.toList(),
          initialLastDate: earlierMessages.lastOrNull?.date.toDate,
        ).reversed.toList(),
      ));
    }
  }

  Future<void> sendMessage({
    List<TextContent>? textContents,
    List<String>? mediaPaths,
    bool hasFadeAnimation = false,
  }) async {
    final String pendingUuid = const Uuid().v4();
    final TextMessage message = TextMessage(
      isPending: true,
      tempId: pendingUuid,
      id: pendingUuid,
      date: DateTime.now(),
      originalTextContents: textContents,
      images: (mediaPaths ?? <String>[]).map(
        (String mediaPath) {
          final String ext = mediaPath.split('.').last;
          final String remoteStorageName = '${const Uuid().v4()}.$ext';

          return Attachment(
            signedUrl: null,
            name: remoteStorageName,
            remoteStorageName: remoteStorageName,
            localFullPath: mediaPath,
            placeholderUrl: null,
          );
        },
      ).toList(),
      improvedTextContents: null,
    );

    _pendingMessages[pendingUuid] = message;
    _emitMessages();
    await _createMessageUseCase.execute(message);
    await _fetchMessages(1, query: null);

    // TODO: bring back task extraction
    // _extractTasks(_sentMessages[message.currentId]! as TextMessage);
  }

  // Future<void> _extractTasks(TextMessage message) async {
  //   final List<Task> tasks = await _extractTasksUseCase.execute(message);

  //   _sentMessages[message.currentId] = message.copyWith(
  //     taskExtractionState: TaskExtractionState(
  //       tasks: tasks,
  //       isAddding: false,
  //       isAdded: false,
  //     ),
  //   );

  //   _emitMessages();
  // }

  Future<void> confirmTasks(TextMessage message) async {
    final TaskExtractionState taskExtractionState =
        message.taskExtractionState!;

    _sentMessages[message.currentId] = message.copyWith(
      taskExtractionState: taskExtractionState.copyWith(
        isAddding: true,
      ),
    );

    _emitMessages();

    await Future<void>.delayed(const Duration(seconds: 2));

    if (_sentMessages.containsKey(message.currentId)) {
      _sentMessages[message.currentId] = message.copyWith(
        taskExtractionState: taskExtractionState.copyWith(
          isAddding: false,
          isAdded: true,
        ),
      );
    }

    _emitMessages();

    await Future<void>.delayed(const Duration(seconds: 2));

    if (_sentMessages.containsKey(message.currentId)) {
      _sentMessages[message.currentId] = message.copyWith(
        taskExtractionState: null,
        tasks: taskExtractionState.tasks,
      );
    }

    _emitMessages();
  }

  void declineTasks(TextMessage message) {
    _sentMessages[message.currentId] = message.copyWith(
      taskExtractionState: null,
    );

    _emitMessages();
  }

  Future<void> editMessage({
    required TextMessage textMessage,
    required List<TextContent> textContents,
    bool refetch = true,
  }) async {
    final TextMessage updatedMessage = switch (textMessage.textEditingTarget) {
      TextEditingTarget.original => textMessage.copyWith(
          originalTextContents: textContents,
          isPending: refetch,
        ),
      TextEditingTarget.enhanced => textMessage.copyWith(
          improvedTextContents: textContents,
          isPending: refetch,
        ),
    };

    _sentMessages[updatedMessage.currentId] = updatedMessage;

    _emitMessages();
    await _editTextMessageUseCase.execute(updatedMessage);

    // TODO: get result from backend

    if (refetch) {
      _sentMessages[updatedMessage.currentId] = updatedMessage.copyWith(
        isPending: false,
      );
      _emitMessages();
    }
  }

  Future<void> pasteFiles() async {
    final String? imageFilePath = await _pasteImageUseCase.execute();
    if (imageFilePath != null) {
      sendMessage(mediaPaths: <String>[imageFilePath]);
    }
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
      transcription: null,
    );

    _pendingMessages[pendingUuid] = message;
    _emitMessages();
    await _createMessageUseCase.execute(message);
    await _fetchMessages(1, query: null);
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
      placeholderUrl: null,
    );

    String? placeholderUrl;
    if (file.fileType == FileType.pdf) {
      placeholderUrl = await _createPdfThumbnailUseCase.execute(file);
    }
    if (file.fileType == FileType.image) {
      placeholderUrl = await _createImageThumbnailUseCase.execute(file);
    }

    final Message message = FileMessage(
      isPending: true,
      id: pendingUuid,
      tempId: pendingUuid,
      date: DateTime.now(),
      file: file.copyWith(
        placeholderUrl: placeholderUrl,
      ),
    );

    _pendingMessages[pendingUuid] = message;
    _emitMessages();
    await _createMessageUseCase.execute(message);
    await _fetchMessages(1, query: null);
  }

  Future<void> deleteMessage({required String messageId}) async {
    state.mapOrNull(
      fetched: (ChatFetched fetched) async {
        _sentMessages.removeWhere((_, Message m) => m.id == messageId);
        _deleteMessagesUseCase.execute(messageId: messageId);
        _emitMessages();
      },
    );
  }

  Future<bool> transcribeAudioMessage(AudioMessage audioMessage) async {
    audioMessage = audioMessage.copyWith(
      transcriptionFailed: false,
    );

    _sentMessages[audioMessage.currentId] = audioMessage;
    _emitMessages();

    state.mapOrNull(
      fetched: (ChatFetched fetched) => emit(
        fetched.copyWith(
          transcribingAudioMessageIds:
              fetched.transcribingAudioMessageIds.toList()
                ..add(audioMessage.currentId),
        ),
      ),
    );

    try {
      final AudioMessage transcribedAudioMessage =
          await _transcribeAudioMessageUseCase.execute(audioMessage);

      if (_sentMessages.containsKey(audioMessage.currentId)) {
        _sentMessages[audioMessage.currentId] = transcribedAudioMessage;
      }

      return true;
    } catch (_) {
      if (_sentMessages.containsKey(audioMessage.currentId)) {
        _sentMessages[audioMessage.currentId] = audioMessage.copyWith(
          transcriptionFailed: true,
        );
      }
      return false;
    } finally {
      state.mapOrNull(
        fetched: (ChatFetched fetched) => emit(
          fetched.copyWith(
            transcribingAudioMessageIds:
                fetched.transcribingAudioMessageIds.toList()
                  ..remove(audioMessage.currentId),
          ),
        ),
      );
      _emitMessages();
    }
  }

  Future<bool> improveText(TextMessage textMessage) async {
    state.mapOrNull(
      fetched: (ChatFetched fetched) => emit(
        fetched.copyWith(
          improvingTextMessageIds: fetched.improvingTextMessageIds.toList()
            ..add(textMessage.currentId),
        ),
      ),
    );

    try {
      final TextMessage improvedMessage =
          await _improveTextUseCase.execute(textMessage);

      if (_sentMessages.containsKey(improvedMessage.currentId)) {
        _sentMessages[improvedMessage.currentId] = improvedMessage;
      }

      return true;
    } catch (_) {
      if (_sentMessages.containsKey(textMessage.currentId)) {
        _sentMessages[textMessage.currentId] = textMessage.copyWith(
          improvementFailed: true,
        );
      }
      return false;
    } finally {
      state.mapOrNull(
        fetched: (ChatFetched fetched) => emit(
          fetched.copyWith(
            improvingTextMessageIds: fetched.improvingTextMessageIds.toList()
              ..remove(textMessage.currentId),
          ),
        ),
      );
      _emitMessages();
    }
  }

  Future<void> undoTextImprovement(TextMessage textMessage) async {
    if (_sentMessages.containsKey(textMessage.currentId)) {
      _sentMessages[textMessage.currentId] = textMessage.copyWith(
        isPending: true,
      );
    }

    _emitMessages();

    final TextMessage updatedMessage =
        await _undoTextImprovementUseCase.execute(textMessage);

    if (_sentMessages.containsKey(updatedMessage.currentId)) {
      _sentMessages[updatedMessage.currentId] = updatedMessage;
    }

    _emitMessages();
  }

  // Helper method to clean up date headers if no messages remain for a specific date
  List<ChatItem> _getChatItems(
    final List<Message> messages, {
    DateTime? initialLastDate,
  }) {
    final List<ChatItem> chatItems = <ChatItem>[];
    DateTime? lastDate = initialLastDate;

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

  @override
  Future<void> close() {
    _processSharingIntentSubscription?.cancel();
    return super.close();
  }
}
