import 'package:injectable/injectable.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: MetrcisRepository)
class MetrcisRepositoryImpl implements MetrcisRepository {
  MetrcisRepositoryImpl(
    this._mixpanelService,
    this._appmetricaService,
  );

  final MixpanelService _mixpanelService;
  final AppmetricaService _appmetricaService;

  @override
  void log(AppEvent appEvent) {
    _mixpanelService.log(appEvent);
    _appmetricaService.log(appEvent);
  }
}
