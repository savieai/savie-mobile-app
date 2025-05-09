import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_dto.freezed.dart';
part 'invite_dto.g.dart';

@freezed
class InviteDTO with _$InviteDTO {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory InviteDTO({
    required DateTime createdAt,
    required String inviterId,
    required String? inviteeId,
    required String code,
    required bool isUsed,
  }) = _InviteDTO;

  const InviteDTO._();

  factory InviteDTO.fromJson(Map<String, Object?> json) =>
      _$InviteDTOFromJson(json);
}
