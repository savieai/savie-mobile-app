import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDTO with _$UserDTO {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserDTO({
    required String id,
    required DateTime createdAt,
    required bool accessAllowed,
    required String userId,
    @Default(false) bool joinWaitlist,
    @Default(false) bool notifyPro,
  }) = _UserDTO;

  const UserDTO._();

  factory UserDTO.fromJson(Map<String, Object?> json) =>
      _$UserDTOFromJson(json);
}
