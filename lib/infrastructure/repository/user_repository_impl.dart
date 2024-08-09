import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(
    this._userApi,
    this._userStorage,
  );

  final UserApi _userApi;
  final UserStorage _userStorage;

  @override
  Future<SavieUser?> fetchUser() async {
    try {
      final HttpResponse<GetUserResponse> response = await _userApi.getUser();
      final UserDTO user = response.data;
      await _userStorage.saveUser(user);
      return UserMapper.toDomain(user);
    } catch (_) {
      return null;
    }
  }

  @override
  SavieUser? getUser() {
    try {
      final UserDTO? dto = _userStorage.getUser();
      if (dto == null) {
        return null;
      }
      return UserMapper.toDomain(dto);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<SavieUser?> watchUser() => _userStorage.watchUser().map(
        (UserDTO? userDto) =>
            userDto == null ? null : UserMapper.toDomain(userDto),
      );
}
