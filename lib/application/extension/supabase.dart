import 'package:supabase_flutter/supabase_flutter.dart';

extension StorageFileApiExtension on StorageFileApi {
  String getAuthenticatedUrl(String path) {
    final String finalPath = '$bucketId/$path';
    const String renderPath = 'object/authenticated';
    return '$url/$renderPath/$finalPath';
  }
}
