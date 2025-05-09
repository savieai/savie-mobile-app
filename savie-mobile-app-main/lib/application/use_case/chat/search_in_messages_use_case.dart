import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class SearchInMessagesUseCase {
  SearchInMessagesUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<(Pagination, List<Message>)> execute({
    required int page,
    required int pageSize,
    required String query,
  }) =>
      _chatRepository.searchInMessages(
        query: query,
        page: page,
        pageSize: pageSize,
      );
}
