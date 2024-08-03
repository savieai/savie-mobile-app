import '../../../../domain/model/savie_user/savie_user.dart';
import '../user/dto/user_dto.dart';

sealed class UserMapper {
  static SavieUser toDomain(UserDTO dto) => SavieUser(
        userId: dto.userId,
        accessAllowed: dto.accessAllowed,
      );
}
