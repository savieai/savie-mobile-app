import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'interceptor/interceptor.dart';

// TODO: have a calss with constants
const String _apiBaseUrl =
    'https://savie-server-production-3fc812ac12c5.herokuapp.com/api/';

// const String _apiBaseUrl =
//     'https://savie-server-4d66a7d3f902.herokuapp.com/api/';

@module
abstract class DioConfigurator {
  @lazySingleton
  Dio configureDio(
    AuthInterceptor authInterceptor,
    ErrorInterceptor errorInterceptor,
  ) {
    final Dio dio = Dio(
      BaseOptions(baseUrl: _apiBaseUrl),
    );

    dio.interceptors.add(authInterceptor);
    dio.interceptors.add(errorInterceptor);

    return dio;
  }
}
