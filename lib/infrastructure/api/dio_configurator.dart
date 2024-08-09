import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'interceptor/interceptor.dart';

// TODO: have a calss with constants
const String _apiBaseUrl =
    'https://savie-server-4d66a7d3f902.herokuapp.com/api/';

@module
abstract class DioConfigurator {
  @lazySingleton
  Dio configureDio(AuthInterceptor authInterceptor) {
    final Dio dio = Dio(
      BaseOptions(baseUrl: _apiBaseUrl),
    );

    dio.interceptors.add(authInterceptor);

    return dio;
  }
}
