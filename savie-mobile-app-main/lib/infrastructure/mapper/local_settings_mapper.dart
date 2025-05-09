import '../../domain/domain.dart';
import '../infrastructure.dart';

sealed class LocalSettingsMapper {
  static LocalSettings toDomain(LocalSettingsDTO dto) {
    return LocalSettings(proPopupShown: dto.proPopupShown);
  }

  static LocalSettingsDTO toDto(LocalSettings settings) {
    return LocalSettingsDTO(proPopupShown: settings.proPopupShown);
  }
}
