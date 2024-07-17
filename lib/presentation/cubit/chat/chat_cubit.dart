import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/domain.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

@Injectable()
class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState(messages: <Message>[]));

  final List<Message> _messages = <Message>[];

  void sendMessage({
    String? message,
    List<String>? mediaPaths,
  }) {
    _messages.add(
      Message(
        id: const Uuid().v4(),
        text: message,
        mediaPaths: mediaPaths ?? <String>[],
      ),
    );

    emit(state.copyWith(
      messages: _messages.toList(),
    ));
  }

  void sendAudio(AudioMessage? audioMessage) {
    _messages.add(
      Message(
        id: const Uuid().v4(),
        audioMessage: audioMessage,
      ),
    );

    emit(state.copyWith(
      messages: _messages.toList(),
    ));
  }
}
