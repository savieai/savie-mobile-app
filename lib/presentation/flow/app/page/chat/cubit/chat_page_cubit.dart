import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../domain/domain.dart';

part 'chat_page_cubit.freezed.dart';

@freezed
class ChatPageState with _$ChatPageState {
  const factory ChatPageState.idle({
    required String preservedText,
  }) = _Idle;
  const factory ChatPageState.editingMessage({
    required TextMessage message,
  }) = _EditingMessage;
}

class ChatPageCubit extends Cubit<ChatPageState> {
  ChatPageCubit() : super(const _Idle(preservedText: ''));

  String _preservedText = '';
  String get preservedText => _preservedText;

  void setEditingMessage(TextMessage message) => emit(
        _EditingMessage(message: message),
      );

  void setIdle() => emit(_Idle(preservedText: _preservedText));

  // ignore: use_setters_to_change_properties
  void updatePreservedText(String text) => _preservedText = text;
}
