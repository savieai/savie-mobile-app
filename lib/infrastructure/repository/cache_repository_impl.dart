import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: CacheRepository)
class CacheRepositoryImpl implements CacheRepository {
  const CacheRepositoryImpl(this._cacheService);

  final MultiKeyCacheService _cacheService;

  @override
  Future<File> cacheFile({
    required String url,
    required String key,
    required File file,
  }) =>
      _cacheService.cacheFile(url: url, key: key, file: file);

  @override
  Stream<(double?, File?)> initiateBackendFileDownload({
    required String url,
    required String key,
  }) =>
      _cacheService.initiateBackendFileDownload(url: url, key: key);

  @override
  Stream<(double?, File?)> getBackendFileStream({
    required String key,
  }) =>
      _cacheService.getBackendFileStream(key);

  @override
  Future<File?> getOtherCachedFile({
    required String key,
  }) =>
      _cacheService.getOtherFile(key: key);
}
