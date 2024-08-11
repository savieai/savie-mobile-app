import 'package:injectable/injectable.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: LocalSettingsRepository)
class LocalSettingsRepositoryImpl implements LocalSettingsRepository {
  LocalSettingsRepositoryImpl(this._settingsStorage);

  final LocalSettingsStorage _settingsStorage;

  @override
  LocalSettings getLocalSettings() {
    final LocalSettingsDTO? dto = _settingsStorage.getLocalSettings();
    final LocalSettings settings =
        dto == null ? LocalSettings.empty : LocalSettingsMapper.toDomain(dto);

    return settings;
  }

  @override
  Future<void> saveLocalSettings(LocalSettings settings) =>
      _settingsStorage.saveLocalSettings(LocalSettingsMapper.toDto(settings));
}
