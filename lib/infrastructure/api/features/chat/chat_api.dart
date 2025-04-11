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
  Future<HttpResponse<GetMessagesResponse>> getMessagesByPage({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET('/messages')
  Future<HttpResponse<GetMessagesResponse>> getMessagesByMessageId({
    @Query('message_id') required String messageId,
    @Query('page_size') required int pageSize,
  });

  @POST('/messages')
  Future<HttpResponse<void>> createMessage(
    @Body() String request,
  );

  @GET('/messages/search')
  Future<HttpResponse<GetMessagesResponse>> searchMessages({
    @Query('q') required String query,
    @Query('type') required String? type,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @DELETE('/messages/{messageId}')
  Future<HttpResponse<void>> deleteMessage(
    @Path('messageId') String messageId,
  );

  @PATCH('/messages/{messageId}')
  Future<HttpResponse<void>> updateMessage(
    @Path('messageId') String messageId,
    @Field('delta_content') Map<String, dynamic> deltaContent,
    @Field('updateTarget') String updateTarget,
  );

  @POST('/messages/{messageId}/revert')
  Future<HttpResponse<void>> undoTextImprovement(
    @Path('messageId') String messageId,
  );
}
