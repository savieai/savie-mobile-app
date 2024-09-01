import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class DeleteMessagesUseCase {
  DeleteMessagesUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<void> execute({required String messageId}) =>
      _chatRepository.removeMessage(messageId: messageId);
}
