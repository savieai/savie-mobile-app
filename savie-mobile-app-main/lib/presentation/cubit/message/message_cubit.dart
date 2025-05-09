import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/model/message.dart';

part 'message_state.dart';
part 'message_cubit.freezed.dart';

class MessageCubit extends Cubit<MessageState> {
  MessageCubit({
    required Message message,
  }) : super(MessageState(message: message));

  void updateMessage(Message message) {
    emit(state.copyWith(message: message));
  }

  void toggleAudioTranscriptionExpansion() => emit(
        state.copyWith(
          isAudioTranscriptionExpanded: !state.isAudioTranscriptionExpanded,
        ),
      );

  void toggleImprovedTextExpansion() => emit(
        state.copyWith(
          isImprovedTextExpanded: !state.isImprovedTextExpanded,
        ),
      );
}
