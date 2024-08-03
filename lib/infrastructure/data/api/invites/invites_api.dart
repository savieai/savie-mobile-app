import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../savie_api_base.dart';

@Singleton()
class InvitesApi {
  InvitesApi(this._apiBase);

  final SavieApiBase _apiBase;

  Future<Response<dynamic>> getInvites() => _apiBase.getData('/invite_codes');
  Future<Response<dynamic>> createInvite() =>
      _apiBase.postData('/invite_codes');
  Future<Response<dynamic>> applyInvite(String code) =>
      _apiBase.putData('/invite_codes/$code');
}
