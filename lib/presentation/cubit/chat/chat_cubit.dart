import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
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
  ) : super(const ChatState(messages: <Message>[])) {
    _fetchMessages();
  }

  final CreateMessageUseCase _createMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final CreatePdfThumbnailUseCase _createPdfThumbnailUseCase;

  Future<void> _fetchMessages() async {
    final List<Message> sentMessages = (await _getMessageUseCase.execute())
      ..sort((Message a, Message b) => a.date.compareTo(b.date));
    _sentMessages = <String, Message>{
      for (final Message m in sentMessages) m.currentId: m
    };
    _pendingMessages.removeWhere(
      (String id, _) => _sentMessages.containsKey(id),
    );
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      if (_pendingMessages.isNotEmpty) ...<Message>[
        ..._pendingMessages.values.take(_pendingMessages.length - 1),
        _pendingMessages.values.last.copyWith(isNew: true),
      ],
    ]));
  }

  final Map<String, Message> _pendingMessages = <String, Message>{};
  Map<String, Message> _sentMessages = <String, Message>{};

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
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      if (_pendingMessages.isNotEmpty) ...<Message>[
        ..._pendingMessages.values.take(_pendingMessages.length - 1),
        _pendingMessages.values.last.copyWith(isNew: true),
      ],
    ]));

    await _createMessageUseCase.execute(message);
    _fetchMessages();
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
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      if (_pendingMessages.isNotEmpty) ...<Message>[
        ..._pendingMessages.values.take(_pendingMessages.length - 1),
        _pendingMessages.values.last.copyWith(isNew: true),
      ],
    ]));

    await _createMessageUseCase.execute(message);
    _fetchMessages();
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
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      if (_pendingMessages.isNotEmpty) ...<Message>[
        ..._pendingMessages.values.take(_pendingMessages.length - 1),
        _pendingMessages.values.last.copyWith(isNew: true),
      ],
    ]));

    await _createMessageUseCase.execute(message);
    _fetchMessages();
  }
}
