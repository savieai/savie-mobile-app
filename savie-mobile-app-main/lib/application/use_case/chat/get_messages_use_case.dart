import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class GetMessageUseCase {
  GetMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<(Pagination, List<Message>)> execute({
    required int page,
    required int pageSize,
  }) =>
      _chatRepository.fetchMessagesByPage(
        page: page,
        pageSize: pageSize,
      );
}
