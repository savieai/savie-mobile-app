import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';

import '../../../api/features/user/dto/dto.dart';

enum _UserKeys {
  user('user');

  const _UserKeys(this.key);

  final String key;
}

@Singleton()
class UserStorage {
  UserStorage(this._sharedPreferences) {
    _seedUserSubject();
  }

  final SharedPreferences _sharedPreferences;
  final BehaviorSubject<UserDTO?> _userSubject = BehaviorSubject<UserDTO?>();

  Future<void> saveUser(UserDTO userDto) async {
    await _sharedPreferences.setString(
      _UserKeys.user.key,
      jsonEncode(userDto),
    );
    _userSubject.add(userDto);
  }

  Stream<UserDTO?> watchUser() => _userSubject.stream;

  UserDTO? getUser() {
    final String? data = _sharedPreferences.getString(_UserKeys.user.key);
    if (data == null) {
      return null;
    }

    return UserDTO.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  void _seedUserSubject() {
    final String? data = _sharedPreferences.getString(_UserKeys.user.key);
    if (data == null) {
      _userSubject.add(null);
      return;
    }

    final UserDTO userDto =
        UserDTO.fromJson(jsonDecode(data) as Map<String, dynamic>);
    _userSubject.add(userDto);
  }
}
