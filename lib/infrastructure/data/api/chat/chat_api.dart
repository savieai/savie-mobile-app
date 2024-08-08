import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../savie_api_base.dart';
import 'request/create_message_request.dart';

@Singleton()
class ChatApi {
  ChatApi(this._apiBase);

  final SavieApiBase _apiBase;

  Future<Response<dynamic>> getMessages() => _apiBase.getData('/messages');
  Future<Response<dynamic>> createMessage(
    CreateMessageRequest request,
  ) {
    return _apiBase.postData(
      '/messages',
      data: request.toJson(),
    );
  }
}
