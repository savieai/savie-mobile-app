import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import '../../application.dart';

@Injectable()
class CreateMessageUseCase {
  CreateMessageUseCase(
    this._createAudioMessageUseCase,
    this._createFileMessageUseCase,
    this._createTextMessageUseCase,
  );

  final CreateAudioMessageUseCase _createAudioMessageUseCase;
  final CreateFileMessageUseCase _createFileMessageUseCase;
  final CreateTextMessageUseCase _createTextMessageUseCase;

  Future<void> execute(Message message) async {
    await message.map(
      text: _createTextMessageUseCase.execute,
      audio: _createAudioMessageUseCase.execute,
      file: _createFileMessageUseCase.execute,
    );
  }
}
