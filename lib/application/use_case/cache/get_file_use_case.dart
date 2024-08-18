import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class GetFileUseCase {
  GetFileUseCase(this._cacheRepository);

  final CacheRepository _cacheRepository;

  Future<File> execute({
    required Attachment attachment,
  }) async {
    return _cacheRepository.getCachedFile(
      url: attachment.remoteUrl ?? attachment.name,
      key: attachment.name,
    );
  }
}
