import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain.dart';

part 'message.freezed.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    String? text,
    @Default(<String>[]) List<String> mediaPaths,
    AudioMessage? audioMessage,
    required DateTime date,
  }) = _Message;
}
