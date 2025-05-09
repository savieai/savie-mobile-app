import '../domain.dart';

abstract class LocalSettingsRepository {
  LocalSettings getLocalSettings();
  Future<void> saveLocalSettings(LocalSettings settings);
}
