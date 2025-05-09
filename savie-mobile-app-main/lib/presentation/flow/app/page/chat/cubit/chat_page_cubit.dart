import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../domain/domain.dart';

part 'chat_page_cubit.freezed.dart';

@freezed
class ChatPageState with _$ChatPageState {
  const factory ChatPageState.idle({
    required Delta preservedDelta,
  }) = _Idle;
  const factory ChatPageState.editingMessage({
    required TextMessage message,
  }) = _EditingMessage;
}

class ChatPageCubit extends Cubit<ChatPageState> {
  ChatPageCubit() : super(_Idle(preservedDelta: Delta()));

  Delta _preservedDelta = Delta();
  Delta get preservedDelta => _preservedDelta;

  void setEditingMessage(TextMessage message) => emit(
        _EditingMessage(message: message),
      );

  void setIdle() => emit(_Idle(preservedDelta: _preservedDelta));

  // ignore: use_setters_to_change_properties
  void updatePreservedDelta(Delta text) => _preservedDelta = text;
}
