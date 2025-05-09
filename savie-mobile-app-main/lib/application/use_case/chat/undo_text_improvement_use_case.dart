import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class UndoTextImprovementUseCase {
  UndoTextImprovementUseCase(
    this._chatRepository,
  );

  final ChatRepository _chatRepository;

  Future<TextMessage> execute(TextMessage message) async {
    await _chatRepository.undoTextImprovement(messageId: message.id);

    final TextMessage updatedMessage = message.copyWith(
      improvedTextContents: null,
      improvementFailed: false,
    );

    return updatedMessage;
  }
}
