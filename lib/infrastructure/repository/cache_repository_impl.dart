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
  Future<File> getBackendCachedFile({
    required String url,
    required String key,
  }) =>
      _cacheService.getBackendFile(url: url, key: key);

  @override
  Future<File?> getOtherCachedFile({
    required String key,
  }) =>
      _cacheService.getOtherFile(key: key);
}
