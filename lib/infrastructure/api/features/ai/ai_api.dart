import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../infrastructure.dart';

export 'dto/dto.dart';
export 'request/request.dart';
export 'response/response.dart';

part 'ai_api.g.dart';

@module
abstract class AiApiModule {
  @singleton
  AiApi getAiApi(Dio dio) => AiApi(dio);
}

@RestApi()
abstract class AiApi {
  factory AiApi(Dio dio, {String baseUrl}) = _AiApi;

  @POST('/ai/transcribe')
  @MultiPart()
  Future<HttpResponse<TranscribeResponse>> transcribe({
    @Part() required File file,
    @Part(name: 'message_id') required String messageId,
  });

  @POST('/ai/enhance')
  Future<HttpResponse<EnhanceResponse>> enhance({
    @Body() required Map<String, dynamic> body,
  });

  @POST('/ai/extract-tasks')
  Future<HttpResponse<ExtractTasksRepsponse>> extractTasks({
    @Body() required Map<String, dynamic> body,
  });
}
