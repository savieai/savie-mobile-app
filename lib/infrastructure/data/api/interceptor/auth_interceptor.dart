import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Injectable()
class AuthInterceptor extends QueuedInterceptorsWrapper {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    options.headers['Authorization'] =
        accessToken == null ? null : 'Bearer $accessToken';

    super.onRequest(options, handler);
  }
}
