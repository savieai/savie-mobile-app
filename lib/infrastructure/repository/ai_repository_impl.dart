import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:retrofit/dio.dart';

import '../../domain/repository/repository.dart';
import '../api/features/ai/ai_api.dart';

@Singleton(as: AiRepository)
class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._api);

  final AiApi _api;

  @override
  Future<String> transcribe({
    required File audioFile,
    required String messageId,
  }) async {
    final HttpResponse<TranscribeResponse> response = await _api.transcribe(
      file: audioFile,
      messageId: messageId,
    );

    return response.data.transcription;
  }

  @override
  Future<String> improveText(String text) async {
    final HttpResponse<EnhanceResponse> response = await _api.enhance(
      body: EnhanceRequest(content: text).toJson(),
    );

    return response.data.enhanced;
  }
}
