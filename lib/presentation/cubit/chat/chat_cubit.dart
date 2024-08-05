import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../application/application.dart';
import '../../../domain/domain.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

@Injectable()
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._createMessageUseCase,
    this._getMessageUseCase,
  ) : super(const ChatState(messages: <Message>[])) {
    _fetchMessages();
  }

  final CreateMessageUseCase _createMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;

  Future<void> _fetchMessages() async {
    final List<Message> messages = await _getMessageUseCase.execute();
    emit(ChatState(messages: messages));
  }

  Future<void> sendMessage({
    String? message,
    List<String>? mediaPaths,
  }) async {
    await _createMessageUseCase.execute(
      imagePaths: mediaPaths ?? <String>[],
      text: message ?? '',
    );

    _fetchMessages();
  }

  void sendAudio(AudioMessage? audioMessage) {
    // _messages.add(
    //   Message(
    //     id: const Uuid().v4(),
    //     audioMessage: audioMessage,
    //     date: DateTime.now(),
    //   ),
    // );

    // emit(state.copyWith(
    //   messages: _messages.toList(),
    // ));
  }
}
