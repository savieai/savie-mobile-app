import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

import '../api/user/dto/dto.dart';

enum _UserKeys {
  user('user');

  const _UserKeys(this.key);

  final String key;
}

@Singleton()
class UserStorage {
  UserStorage(this._sharedPreferences) {
    _userSubject = BehaviorSubject<UserDTO?>.seeded(getUser());
  }

  final SharedPreferences _sharedPreferences;
  late final BehaviorSubject<UserDTO?> _userSubject;

  Future<void> saveUser(UserDTO userDto) => _sharedPreferences.setString(
        _UserKeys.user.key,
        jsonEncode(userDto),
      );

  Stream<UserDTO?> watchUser() => _userSubject.stream;

  UserDTO? getUser() {
    final String? data = _sharedPreferences.getString(_UserKeys.user.key);
    if (data == null) {
      return null;
    }

    return UserDTO.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }
}
