// ignore_for_file: invalid_annotation_target

import 'package:injectable/injectable.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

@module
abstract class RegisterModule {
  @singleton
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @singleton
  RxSharedPreferences rxSharedPreferences(
    SharedPreferences sharedPreferences,
  ) =>
      RxSharedPreferences(sharedPreferences);
}
