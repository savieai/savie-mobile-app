import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    super.key,
    required this.attachment,
    this.fit,
    this.height,
    this.width,
    this.filterQuality,
    this.memCacheHeight,
  });

  final Attachment attachment;
  final BoxFit? fit;
  final double? height;
  final double? width;
  final FilterQuality? filterQuality;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    if (attachment.remoteUrl != null) {
      return CachedNetworkImage(
        cacheKey: attachment.name,
        imageUrl: attachment.remoteUrl!,
        httpHeaders: <String, String>{
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsdXdjYmZveXphd2VjY21haHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkzODkyNjQsImV4cCI6MjAzNDk2NTI2NH0.F-NoFb0zV5QaaM_S4VhiDA9lf7ShNo6GYIPCCi9XQSQ',
          'Authorization':
              'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
        },
        fit: fit,
        height: height,
        width: width,
        filterQuality: filterQuality ?? FilterQuality.low,
        memCacheHeight: memCacheHeight,
      );
    } else if (attachment.localUrl != null) {
      return Image.file(
        File(attachment.localUrl!),
        fit: fit,
        height: height,
        width: width,
        filterQuality: filterQuality ?? FilterQuality.low,
        cacheHeight: memCacheHeight,
      );
    }

    return const SizedBox();
  }
}

ImageProvider? getCustomImageProvider(
  Attachment attachment,
) {
  if (attachment.remoteUrl != null) {
    return CachedNetworkImageProvider(
      attachment.remoteUrl!,
      cacheKey: attachment.name,
      headers: <String, String>{
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsdXdjYmZveXphd2VjY21haHllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTkzODkyNjQsImV4cCI6MjAzNDk2NTI2NH0.F-NoFb0zV5QaaM_S4VhiDA9lf7ShNo6GYIPCCi9XQSQ',
        'Authorization':
            'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
      },
    );
  } else if (attachment.localUrl != null) {
    return FileImage(
      File(attachment.localUrl!),
    );
  }

  return null;
}
