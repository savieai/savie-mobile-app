import 'package:injectable/injectable.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../../domain/model/model.dart';

@Singleton()
class MixpanelService {
  @PostConstruct()
  void init() => Mixpanel.init('a45f41434bf6d3c1b8e701113bedbf2c',
      trackAutomaticEvents: false);

  Future<void> log(AppEvent appEvent) {
    return Mixpanel('a45f41434bf6d3c1b8e701113bedbf2c').track(
      appEvent.name,
      properties: appEvent.params,
    );
  }
}
