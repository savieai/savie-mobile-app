import 'package:freezed_annotation/freezed_annotation.dart';

import '../../dto/invite_dto.dart';

part 'get_invites_response.freezed.dart';

@freezed
class GetInvitesResponse with _$GetInvitesResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GetInvitesResponse({
    required List<InviteDTO> invites,
  }) = _GetInvitesResponse;

  const GetInvitesResponse._();

  static GetInvitesResponse fromJson(List<dynamic> json) => GetInvitesResponse(
        invites: json
            .map((dynamic e) => InviteDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
