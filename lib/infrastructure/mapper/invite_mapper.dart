import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class InviteMapper {
  static Invite toDomain(InviteDTO dto) => Invite(
        code: dto.code,
        isUsed: dto.isUsed,
      );
}
