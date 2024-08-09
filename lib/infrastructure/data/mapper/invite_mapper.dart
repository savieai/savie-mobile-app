import '../../../domain/model/invite/invite.dart';
import '../api/invites/dto/invite_dto.dart';

sealed class InviteMapper {
  static Invite toDomain(InviteDTO dto) => Invite(
        code: dto.code,
        isUsed: dto.isUsed,
      );
}
