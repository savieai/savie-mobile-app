import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/dio.dart';

import '../../domain/domain.dart';
import '../api/features/ai/ai_api.dart';
import '../mapper/mapper.dart';

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
  Future<List<TextContent>> improveText({
    required List<TextContent> textContents,
    required String messageId,
  }) async {
    final HttpResponse<EnhanceResponse> response = await _api.enhance(
      body: EnhanceRequest(
        content: <String, dynamic>{
          'ops': TextContent.toDelta(textContents).toJson(),
        },
        format: 'delta',
        messageId: messageId,
        force: false,
      ).toJson(),
    );

    return TextContent.fromDelta(
      MessageMapper.parseDelta(response.data.enhanced),
    );
  }

  @override
  Future<List<Task>> extractTasks({
    required String plainTextContent,
    required String messageId,
  }) async {
    final HttpResponse<ExtractTasksRepsponse> response =
        await _api.extractTasks(
      body: ExtractTasksRequest(
        content: plainTextContent,
        messageId: messageId,
      ).toJson(),
    );

    return response.data.tasks.map(TaskMapper.toDomain).toList();
  }
}
