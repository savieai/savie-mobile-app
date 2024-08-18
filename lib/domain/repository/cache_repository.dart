import 'dart:io';

abstract interface class CacheRepository {
  Future<File> cacheFile({
    required String url,
    required String key,
    required File file,
  });

  Future<File> getCachedFile({
    required String url,
    required String key,
  });
}
