import 'dart:io';

abstract interface class CacheRepository {
  Future<File> cacheFile({
    required String url,
    required String key,
    required File file,
  });

  Stream<(double?, File?)> initiateBackendFileDownload({
    required String url,
    required String key,
  });

  Stream<(double?, File?)> getBackendFileStream({
    required String key,
  });

  Future<File?> getOtherCachedFile({
    required String key,
  });
}
