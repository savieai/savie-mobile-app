import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class GetFileStreamUseCase {
  GetFileStreamUseCase(this._cacheRepository);

  final CacheRepository _cacheRepository;

  Stream<(double?, File?)> execute({
    required String name,
  }) =>
      _cacheRepository.getBackendFileStream(key: name);
}
