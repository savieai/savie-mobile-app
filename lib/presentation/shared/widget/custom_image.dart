import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    );
  } else if (attachment.localUrl != null) {
    return FileImage(
      File(attachment.localUrl!),
    );
  }

  return null;
}
