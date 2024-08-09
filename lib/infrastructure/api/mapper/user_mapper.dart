import '../../../domain/domain.dart';
import '../../infrastructure.dart';

sealed class UserMapper {
  static SavieUser toDomain(UserDTO dto) => SavieUser(
        userId: dto.userId,
        accessAllowed: dto.accessAllowed,
      );
}
