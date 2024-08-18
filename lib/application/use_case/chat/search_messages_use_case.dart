import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class SearchMessagesUseCase {
  SearchMessagesUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<SearchResult>> execute({
    required String query,
    required SearchResultType type,
  }) =>
      _chatRepository.searchMessages(query: query, type: type);
}
