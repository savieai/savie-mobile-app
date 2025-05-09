import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../infrastructure.dart';

export 'dto/dto.dart';
export 'response/response.dart';

part 'invites_api.g.dart';

@module
abstract class InvitesApiModule {
  @singleton
  InvitesApi getInvitesApi(Dio dio) => InvitesApi(dio);
}

@RestApi()
abstract class InvitesApi {
  factory InvitesApi(Dio dio, {String baseUrl}) = _InvitesApi;

  @GET('/invite_codes')
  Future<HttpResponse<GetInvitesResponse>> getInvites();

  @POST('/invite_codes')
  Future<HttpResponse<CreateInviteResponse>> createInvite();

  @PUT('/invite_codes/{code}')
  Future<HttpResponse<void>> applyInvite(@Path('code') String code);
}
