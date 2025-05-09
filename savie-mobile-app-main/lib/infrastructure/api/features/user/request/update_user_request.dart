import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_user_request.freezed.dart';
part 'update_user_request.g.dart';

@freezed
class UpdateUserRequest with _$UpdateUserRequest {
  @JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
  const factory UpdateUserRequest({
    required bool joinWaitlist,
    required bool notifyPro,
  }) = _UpdateUserRequest;

  const UpdateUserRequest._();

  factory UpdateUserRequest.fromJson(Map<String, Object?> json) =>
      _$UpdateUserRequestFromJson(json);
}
