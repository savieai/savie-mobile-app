import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class EditTextMessageUseCase {
  EditTextMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> execute(TextMessage message) async {
    await _chatRepository.editMessage(
      messageId: message.id,
      textContent: message.text ?? '',
    );
  }
}
