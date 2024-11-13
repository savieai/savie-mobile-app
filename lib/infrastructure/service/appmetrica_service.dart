import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:injectable/injectable.dart';

import '../../domain/model/model.dart';

@Singleton()
class AppmetricaService {
  @PostConstruct()
  void init() {
    if (Platform.isMacOS) {
      return;
    }

    AppMetrica.activate(
      const AppMetricaConfig('cb45ae07-418f-43bb-8559-420ec040b520'),
    );
  }

  Future<void> log(AppEvent appEvent) async {
    if (Platform.isMacOS) {
      return;
    }

    return AppMetrica.reportEventWithMap(
      appEvent.name,
      appEvent.params,
    );
  }
}
