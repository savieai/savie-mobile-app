import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:injectable/injectable.dart';

import '../../domain/model/model.dart';

@Singleton()
class AppmetricaService {
  @PostConstruct()
  void init() {
    // Disable AppMetrica completely
    return;
  }

  Future<void> log(AppEvent appEvent) async {
    // Disable AppMetrica logging
    return;
  }
}
