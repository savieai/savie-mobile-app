import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class FindMessageUseCase {
  FindMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<(Pagination, List<Message>)> execute({
    required String messageId,
    required int pageSize,
  }) =>
      _chatRepository.fetchMessagesByMessageId(
        messageId: messageId,
        pageSize: pageSize,
      );
}
