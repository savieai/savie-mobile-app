import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../savie_api_base.dart';

@Singleton()
class UserApi {
  UserApi(this._apiBase);

  final SavieApiBase _apiBase;

  Future<Response<dynamic>> getUser() => _apiBase.getData('/users/self');
}
