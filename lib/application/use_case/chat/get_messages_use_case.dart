import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class GetMessageUseCase {
  GetMessageUseCase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<Message>> execute() => _chatRepository.fetchMessages();
}
