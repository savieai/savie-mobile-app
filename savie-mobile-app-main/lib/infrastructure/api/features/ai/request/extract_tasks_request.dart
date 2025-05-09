import 'package:freezed_annotation/freezed_annotation.dart';

part 'extract_tasks_request.freezed.dart';
part 'extract_tasks_request.g.dart';

@freezed
class ExtractTasksRequest with _$ExtractTasksRequest {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ExtractTasksRequest({
    required String content,
    required String messageId,
  }) = _ExtractTasksRequest;

  const ExtractTasksRequest._();

  factory ExtractTasksRequest.fromJson(Map<String, Object?> json) =>
      _$ExtractTasksRequestFromJson(json);
}
