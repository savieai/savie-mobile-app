import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../domain/model/message.dart';
import '../../../domain/repository/repository.dart';

@Injectable()
class ImproveTextUseCase {
  ImproveTextUseCase(
    this._aiRepository,
  );

  final AiRepository _aiRepository;

  Future<TextMessage> execute(TextMessage message) async {
    final String? delta = message.deltaContent == null
        ? null
        : jsonEncode(message.deltaContent!.toJson());

    final String improvedText = await _aiRepository.improveText(delta ?? '');

    final TextMessage updatedMessage = message.copyWith(
      improvedText: improvedText,
    );

    return updatedMessage;
  }
}
