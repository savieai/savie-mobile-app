import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class UserMapper {
  static SavieUser toDomain(UserDTO dto) => SavieUser(
        id: dto.id,
        userId: dto.userId,
        accessAllowed: dto.accessAllowed,
        joinWaitlist: dto.joinWaitlist,
        notifyPro: dto.notifyPro,
      );
}
