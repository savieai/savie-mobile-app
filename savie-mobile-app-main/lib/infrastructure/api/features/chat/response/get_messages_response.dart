import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../infrastructure.dart';

part 'get_messages_response.freezed.dart';
part 'get_messages_response.g.dart';

@freezed
class GetMessagesResponse with _$GetMessagesResponse {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
  )
  const factory GetMessagesResponse({
    required GetMessagesResponseData data,
  }) = _GetMessagesResponse;

  const GetMessagesResponse._();

  factory GetMessagesResponse.fromJson(Map<String, Object?> json) =>
      _$GetMessagesResponseFromJson(json);
}

@freezed
class GetMessagesResponseData with _$GetMessagesResponseData {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    explicitToJson: true,
  )
  const factory GetMessagesResponseData({
    required List<MessageDTO> messages,
    required PaginationDTO pagination,
  }) = _GetMessagesResponseData;

  const GetMessagesResponseData._();

  factory GetMessagesResponseData.fromJson(Map<String, Object?> json) =>
      _$GetMessagesResponseDataFromJson(json);
}
