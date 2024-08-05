import 'package:freezed_annotation/freezed_annotation.dart';

import '../dto/message_dto.dart';

part 'get_messages_response.freezed.dart';

@freezed
class GetMessagesResponse with _$GetMessagesResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GetMessagesResponse({
    required List<MessageDTO> messages,
  }) = _GetMessagesResponse;

  const GetMessagesResponse._();

  static GetMessagesResponse fromJson(List<dynamic> json) =>
      GetMessagesResponse(
        messages: json
            .map((dynamic e) => MessageDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
