import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final File result = await _cacheManager.getSingleFile(
      url,
      key: key,
      headers: <String, String>{
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsdXdjYmZveXphd2VjY21haHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkzODkyNjQsImV4cCI6MjAzNDk2NTI2NH0.F-NoFb0zV5QaaM_S4VhiDA9lf7ShNo6GYIPCCi9XQSQ',
        'Authorization':
            'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
      },
    );
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
