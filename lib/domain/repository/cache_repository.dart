import 'dart:io';

abstract interface class CacheRepository {
  Future<File> cacheFile({
    required String url,
    required String key,
    required File file,
  });

  Future<File> getBackendCachedFile({
    required String url,
    required String key,
  });

  Future<File?> getOtherCachedFile({
    required String key,
  });
}
