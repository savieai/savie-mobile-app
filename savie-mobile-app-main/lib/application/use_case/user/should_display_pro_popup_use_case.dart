import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class ShouldDisplaySavieProPopupUseCase {
  ShouldDisplaySavieProPopupUseCase(this._localSettingsRepository);

  final LocalSettingsRepository _localSettingsRepository;

  bool execute() => !_localSettingsRepository.getLocalSettings().proPopupShown;
}
