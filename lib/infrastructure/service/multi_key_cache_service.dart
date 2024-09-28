import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Singleton()
class MultiKeyCacheService {
  final CacheManager _cacheManager = DefaultCacheManager();

  final Map<String, File> _lastFiles = <String, File>{};

  final Map<String, BehaviorSubject<(double?, File?)>>
      _ongoingDownloadSubjects = <String, BehaviorSubject<(double?, File?)>>{};

// Method to return the stream, but it doesn't start the download
  Stream<(double?, File?)> getBackendFileStream(String key) async* {
    // If there's an ongoing download, return the existing stream controller's stream
    if (_ongoingDownloadSubjects.containsKey(key)) {
      yield* _ongoingDownloadSubjects[key]!.stream;
      return;
    }

    // If the file is already cached, return a completed stream with the cached file
    if (_lastFiles.containsKey(key)) {
      yield* Stream<(double?, File?)>.value((1.0, _lastFiles[key]));
      return;
    }

    // If file exists in cache
    final FileInfo? file = await _cacheManager.getFileFromCache(key);
    if (file != null) {
      _lastFiles[key] = file.file;
      yield* Stream<(double?, File?)>.value((1.0, _lastFiles[key]));
      return;
    }

    // If the download hasn't started yet, return a stream that emits null
    final BehaviorSubject<(double?, File?)> subject =
        BehaviorSubject<(double?, File?)>();
    _ongoingDownloadSubjects[key] = subject;

    yield* subject.stream;
  }

  // Method to start the file download (initiates the stream)
  Stream<(double?, File?)> initiateBackendFileDownload({
    required String url,
    required String key,
  }) async* {
    // If the file is already cached, return it immediately
    if (_lastFiles.containsKey(key)) {
      yield* Stream<(double?, File?)>.value((1.0, _lastFiles[key]));
    }

    if (_ongoingDownloadSubjects.containsKey(key)) {
      if (_ongoingDownloadSubjects[key]!.hasValue) {
        yield* _ongoingDownloadSubjects[key]!.stream;
      }
    } else {
      final BehaviorSubject<(double?, File?)> subject =
          BehaviorSubject<(double?, File?)>();
      _ongoingDownloadSubjects[key] = subject;
    }

    final FileInfo? file = await _cacheManager.getFileFromCache(key);
    if (file != null) {
      _lastFiles[key] = file.file;
      _ongoingDownloadSubjects[key]!.add((1.0, file.file));

      yield* Stream<(double?, File?)>.value((1.0, _lastFiles[key]));
      return;
    }

    _ongoingDownloadSubjects[key]!.add((null, null));

    // Start the download and listen to the progress
    _cacheManager
        .getFileStream(
      url,
      key: key,
      headers: <String, String>{
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFveXphd2VjY21haHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkzODkyNjQsImV4cCI6MjAzNDk2NTI2NH0.F-NoFb0zV5QaaM_S4VhiDA9lf7ShNo6GYIPCCi9XQSQ',
        'Authorization':
            'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
      },
      withProgress: true,
    )
        .listen((FileResponse downloadEvent) {
      if (downloadEvent is DownloadProgress) {
        _ongoingDownloadSubjects[key]!
            .add((downloadEvent.progress ?? 0.0, null));
      } else if (downloadEvent is FileInfo) {
        final File result = downloadEvent.file;
        _lastFiles[key] = result;
        _ongoingDownloadSubjects[key]!.add((1.0, result));
        _ongoingDownloadSubjects[key]!.close();
        _ongoingDownloadSubjects.remove(key); // Clean up ongoing download
      }
    });

    yield* _ongoingDownloadSubjects[key]!.stream;
  }

  bool hasFileInRuntime(String key) => _lastFiles.containsKey(key);

  File? getFileSync(String key) {
    if (_lastFiles.containsKey(key)) {
      return _lastFiles[key];
    }
    return null;
  }

  Future<File?> getOtherFile({
    required String key,
  }) async {
    if (_lastFiles.containsKey(key)) {
      return _lastFiles[key]!;
    }

    final FileInfo? result = await _cacheManager.getFileFromCache(
      key,
    );

    if (result != null) {
      _lastFiles[key] = result.file;
      return result.file;
    }

    return null;
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
