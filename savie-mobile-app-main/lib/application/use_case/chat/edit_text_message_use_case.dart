import 'package:flutter_quill/quill_delta.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class EditTextMessageUseCase {
  EditTextMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> execute(TextMessage message) async {
    await _chatRepository.editMessageTextContent(
      messageId: message.id,
      deltaContent: message.currentDeltaContent ?? (Delta()..insert('')),
      target: message.textEditingTarget,
    );
  }
}
