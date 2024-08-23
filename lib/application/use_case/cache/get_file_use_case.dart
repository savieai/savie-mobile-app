import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class GetFileUseCase {
  GetFileUseCase(this._cacheRepository);

  final CacheRepository _cacheRepository;

  Future<File> execute({
    required String? localFullPath,
    required String? signedUrl,
    required String name,
  }) async {
    return _cacheRepository.getCachedFile(
      url: signedUrl ?? localFullPath!,
      key: name,
    );
  }
}
