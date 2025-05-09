import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../domain/model/message.dart';
import '../../../domain/repository/repository.dart';
import '../use_case.dart';

@Injectable()
class TranscribeAudioMessageUseCase {
  TranscribeAudioMessageUseCase(
    this._aiRepository,
    this._getFileStreamUseCase,
    // this._chatRepository,
  );

  final AiRepository _aiRepository;
  final GetFileStreamUseCase _getFileStreamUseCase;
  // final ChatRepository _chatRepository;

  Future<AudioMessage> execute(AudioMessage message) async {
    final Stream<(double?, File?)> audioStream =
        _getFileStreamUseCase.execute(name: message.audioInfo.name);

    late File audioFile;

    await for (final (double?, File?) chunk in audioStream) {
      if (chunk.$2 != null) {
        audioFile = chunk.$2!;
      }
    }

    final String transcription = await _aiRepository.transcribe(
      audioFile: File(audioFile.path),
      messageId: message.id,
    );

    final AudioMessage updatedAudioMessage = message.copyWith(
      transcription: transcription,
    );

    return updatedAudioMessage;
  }
}
