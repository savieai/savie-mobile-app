import 'package:dio/dio.dart';
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
    } on DioException catch (_) {
      return getUser();
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

  @override
  Future<bool> updateUser(SavieUser user) async {
    final UpdateUserRequest request = UpdateUserRequest(
      joinWaitlist: user.joinWaitlist,
      notifyPro: user.notifyPro,
    );

    final HttpResponse<void> response = await _userApi.updateUser(
      id: user.id,
      request: request,
    );

    return response.response.statusCode == 200;
  }

  @override
  Future<bool> deleteUser() async {
    final UserDTO? dto = _userStorage.getUser();
    if (dto == null) {
      return false;
    }

    final HttpResponse<void> response = await _userApi.deleteUser(
      userId: dto.userId,
    );

    return response.response.statusCode == 200;
  }
}
