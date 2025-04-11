import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class ImproveTextUseCase {
  ImproveTextUseCase(
    this._aiRepository,
  );

  final AiRepository _aiRepository;

  Future<TextMessage> execute(TextMessage message) async {
    final List<TextContent> improvedTextContents =
        await _aiRepository.improveText(
      textContents: message.originalTextContents ?? <TextContent>[],
      messageId: message.id,
    );

    final TextMessage updatedMessage = message.copyWith(
      improvedTextContents: improvedTextContents,
      improvementFailed: false,
    );

    return updatedMessage;
  }
}
