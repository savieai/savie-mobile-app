import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../infrastructure.dart';

export 'dto/dto.dart';
export 'request/request.dart';
export 'response/response.dart';

part 'chat_api.g.dart';

@module
abstract class ChatApiModule {
  @singleton
  ChatApi getChatApi(Dio dio) => ChatApi(dio);
}

@RestApi()
abstract class ChatApi {
  factory ChatApi(Dio dio, {String baseUrl}) = _ChatApi;

  @GET('/messages')
  Future<HttpResponse<GetMessagesResponse>> getMessages();

  @POST('/messages')
  Future<HttpResponse<void>> createMessage(
    @Body() String request,
  );

  @GET('/messages/search')
  Future<HttpResponse<void>> searchMessages(
    @Query('q') String query,
    @Query('type') String type,
  );
}
