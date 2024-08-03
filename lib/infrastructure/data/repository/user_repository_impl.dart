import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import '../../../domain/model/savie_user/savie_user.dart';
import '../../../domain/repository/repository.dart';
import '../api/mapper/user_mapper.dart';
import '../api/user/dto/user_dto.dart';
import '../api/user/user_api.dart';
import '../sotrage/user_storage.dart';

//TODO: create user storage

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
      final Response<dynamic> response = await _userApi.getUser();
      final UserDTO user =
          UserDTO.fromJson(response.data as Map<String, dynamic>);
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
