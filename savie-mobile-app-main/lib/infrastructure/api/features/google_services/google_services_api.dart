import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../infrastructure.dart';

export 'response/response.dart';

part 'google_services_api.g.dart';

@module
abstract class GoogleServicesApiModule {
  @singleton
  GoogleServicesApi getCalendarApi(Dio dio) => GoogleServicesApi(dio);
}

@RestApi()
abstract class GoogleServicesApi {
  factory GoogleServicesApi(Dio dio, {String baseUrl}) = _GoogleServicesApi;

  @GET('/services/connect/google')
  Future<HttpResponse<ConnectResponse>> connect();
}
