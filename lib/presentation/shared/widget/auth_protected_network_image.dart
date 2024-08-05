import 'dart:typed_data';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProtectedNetworkImage extends StatelessWidget {
  const AuthProtectedNetworkImage(
    this.imageUrl, {
    super.key,
    this.fit,
    this.height,
    this.width,
    this.filterQuality,
    this.cacheHeight,
  });

  final String imageUrl;
  final BoxFit? fit;
  final double? height;
  final double? width;
  final FilterQuality? filterQuality;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Supabase.instance.client.storage
            .from('message_attachments')
            .download(imageUrl),
        builder: (BuildContext context, AsyncSnapshot<Uint8List> snaphot) {
          if (snaphot.data == null) {
            return const SizedBox();
          }

          return CachedMemoryImage(
            // imageUrl: imageUrl,
            // httpHeaders: <String, String>{
            //   'Authorization':
            //       'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}',
            // },
            uniqueKey: imageUrl,
            bytes: snaphot.data,
            fit: fit,
            height: height,
            width: width,
            filterQuality: filterQuality ?? FilterQuality.low,
            cacheHeight: cacheHeight,
          );
        });
  }
}

sealed class AuthProtectedNetworkImageProvider {
  static CachedMemoryImageProvider getProvider(
    String imageUrl, {
    Uint8List? bytes,
  }) =>
      CachedMemoryImageProvider(
        imageUrl,
        bytes: bytes,
      );
}
