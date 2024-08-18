import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class MultiKeyCacheService {
  final CacheManager _cacheManager = DefaultCacheManager();

  final Map<String, File> _lastFiles = <String, File>{};

  Future<File> getFile({
    required String url,
    required String key,
  }) async {
    if (_lastFiles.containsKey(key)) {
      return _lastFiles[key]!;
    }

    final File result = await _cacheManager.getSingleFile(url, key: key);
    _lastFiles[key] = result;

    return result;
  }

  Future<File> cacheFile({
    required String url,
    required String key,
    required File file,
  }) async {
    final File result = await _cacheManager.putFile(
      url,
      file.readAsBytesSync(),
      key: key,
      fileExtension: file.path.split('.').last,
    );

    _lastFiles[key] = result;
    return result;
  }
}
