import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class ExtractTasksUseCase {
  ExtractTasksUseCase(this._aiRepository);

  final AiRepository _aiRepository;

  Future<List<Task>> execute(TextMessage message) async {
    return _aiRepository.extractTasks(
      plainTextContent: message.currentPlainText ?? '',
      messageId: message.id,
    );
  }
}
