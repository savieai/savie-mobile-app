import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

import '../../../infrastructure.dart';

export 'dto/dto.dart';

enum _LocalSettingsKeys {
  localSettings('local_settings');

  const _LocalSettingsKeys(this.key);

  final String key;
}

@Singleton()
class LocalSettingsStorage {
  LocalSettingsStorage(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<void> saveLocalSettings(LocalSettingsDTO localSettingsDto) async {
    await _sharedPreferences.setString(
      _LocalSettingsKeys.localSettings.key,
      jsonEncode(localSettingsDto),
    );
  }

  LocalSettingsDTO? getLocalSettings() {
    final String? data = _sharedPreferences.getString(
      _LocalSettingsKeys.localSettings.key,
    );

    if (data == null) {
      return null;
    }

    return LocalSettingsDTO.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }
}
