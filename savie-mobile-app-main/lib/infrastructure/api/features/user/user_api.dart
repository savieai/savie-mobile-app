import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../infrastructure.dart';

export 'dto/dto.dart';
export 'request/request.dart';
export 'response/response.dart';

part 'user_api.g.dart';

@module
abstract class UserApiModule {
  @singleton
  UserApi getUserApi(Dio dio) => UserApi(dio);
}

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio) = _UserApi;

  @GET('/users/self')
  Future<HttpResponse<GetUserResponse>> getUser();

  @PATCH('/users/{id}')
  Future<HttpResponse<void>> updateUser({
    @Path() required String id,
    @Body() required UpdateUserRequest request,
  });

  @DELETE('/users/{userId}')
  Future<HttpResponse<void>> deleteUser({
    @Path() required String userId,
  });
}
