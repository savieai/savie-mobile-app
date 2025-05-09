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
  }) {
    // Convert the stream into a future that completes when the file is downloaded
    return _cacheRepository
        .initiateBackendFileDownload(
          url: signedUrl ?? localFullPath!,
          key: name,
        )
        .firstWhere(((double?, File?) event) => event.$2 != null)
        .then(((double?, File?) event) => event.$2!);
  }
}
