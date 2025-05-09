import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class SetProPopupDisplayedUseCase {
  SetProPopupDisplayedUseCase(this._localSettingsRepository);

  final LocalSettingsRepository _localSettingsRepository;

  Future<bool> execute() async {
    final LocalSettings settings = _localSettingsRepository.getLocalSettings();
    await _localSettingsRepository.saveLocalSettings(
      settings.copyWith(proPopupShown: true),
    );
    return _localSettingsRepository.getLocalSettings().proPopupShown;
  }
}
