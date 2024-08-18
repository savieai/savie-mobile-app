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

  Future<void> _fetchMessages({String? pendingIdToRemove}) async {
    final List<Message> messages = await _getMessageUseCase.execute();
    _sentMessages = <String, Message>{
      for (final Message m in messages) m.id: m
    };
    _pendingMessages.remove(pendingIdToRemove);
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      ..._pendingMessages.values,
    ]));
  }

  final Map<String, Message> _pendingMessages = <String, Message>{};
  Map<String, Message> _sentMessages = <String, Message>{};

  Future<void> sendMessage({
    String? text,
    List<String>? mediaPaths,
  }) async {
    final String pendingUuid = const Uuid().v4();
    final Message message = TextMessage(
      isPending: true,
      id: pendingUuid,
      date: DateTime.now(),
      text: text,
      images: (mediaPaths ?? <String>[]).map(
        (String mediaPath) {
          final String ext = mediaPath.split('.').last;
          return Attachment(
            name: '${const Uuid().v4()}.$ext',
            remoteUrl: null,
            localUrl: mediaPath,
          );
        },
      ).toList(),
    );

    _pendingMessages[pendingUuid] = message;
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      ..._pendingMessages.values,
    ]));

    await _createMessageUseCase.execute(message);
    _fetchMessages(pendingIdToRemove: pendingUuid);
  }

  Future<void> sendAudio(String? audioPath) async {
    if (audioPath == null) {
      return;
    }

    final String pendingUuid = const Uuid().v4();
    final String ext = audioPath.split('.').last;

    final Message message = AudioMessage(
      isPending: true,
      id: pendingUuid,
      date: DateTime.now(),
      name: '${const Uuid().v4()}.$ext',
      remoteUrl: null,
      localUrl: audioPath,
    );

    _pendingMessages[pendingUuid] = message;
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      ..._pendingMessages.values,
    ]));

    await _createMessageUseCase.execute(message);
    _fetchMessages(pendingIdToRemove: pendingUuid);
  }

  Future<void> sendFile(String? filePath) async {
    if (filePath == null) {
      return;
    }

    final String pendingUuid = const Uuid().v4();
    final String ext = filePath.split('.').last;

    final Attachment file = Attachment(
      name: '${const Uuid().v4()}.$ext',
      remoteUrl: null,
      localUrl: filePath,
    );

    final Message message = FileMessage(
      isPending: true,
      id: pendingUuid,
      date: DateTime.now(),
      file: file,
    );

    if (file.fileType == FileType.pdf) {
      await _createPdfThumbnailUseCase.execute(file);
    }

    _pendingMessages[pendingUuid] = message;
    emit(ChatState(messages: <Message>[
      ..._sentMessages.values,
      ..._pendingMessages.values,
    ]));

    await _createMessageUseCase.execute(message);
    _fetchMessages(pendingIdToRemove: pendingUuid);
  }
}
