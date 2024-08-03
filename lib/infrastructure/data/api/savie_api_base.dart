import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'interceptor/interceptor.dart';

const String _apiBaseUrl =
    'https://savie-server-4d66a7d3f902.herokuapp.com/api';

@Singleton()
class SavieApiBase {
  SavieApiBase(this._authInterceptor) {
    _dio = _createDio();
  }

  final AuthInterceptor _authInterceptor;

  late final Dio _dio;

  Dio _createDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: _apiBaseUrl,
      ),
    );

    dio.interceptors.add(_authInterceptor);

    return dio;
  }

  Future<Response<dynamic>> getData(
    String endpoint, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
    Map<String, Object?> data = const <String, Object?>{},
  }) =>
      _dio.get(
        endpoint,
        queryParameters: queryParameters,
        data: data,
      );

  Future<Response<dynamic>> postData(
    String endpoint, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
    Map<String, Object?> data = const <String, Object?>{},
  }) =>
      _dio.post(
        endpoint,
        queryParameters: queryParameters,
        data: data,
      );

  Future<Response<dynamic>> putData(
    String endpoint, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
    Map<String, Object?> data = const <String, Object?>{},
  }) =>
      _dio.put(
        endpoint,
        queryParameters: queryParameters,
        data: data,
      );
}
