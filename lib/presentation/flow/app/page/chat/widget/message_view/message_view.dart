import 'dart:math';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../../application/application.dart';
import '../../../../../../../domain/domain.dart';
import '../../../../../../presentation.dart';
import '../../../../../../router/app_router.gr.dart';
import '../widget.dart';

part 'media_message_view.dart';
part 'audio_message_view.dart';
part 'text_message_view.dart';
part 'message_container.dart';
part 'text_with_media_message_view.dart';

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return MessageTimeWrapper(
      time: message.date,
      child: _MessageAligner(
        child: ContextMenuRegion(
          heroTag: '${message.id}_context_menu',
          data: <ContextMenuItemData>[
            ContextMenuItemData(
              title: 'Edit',
              icon: Assets.icons.edit16,
              color: AppColors.textPrimary,
              onTap: () {},
            ),
            ContextMenuItemData(
              title: 'Copy',
              icon: Assets.icons.copy16,
              color: AppColors.textPrimary,
              onTap: () {},
            ),
            ContextMenuItemData(
              title: 'Pin',
              icon: Assets.icons.pin16,
              color: AppColors.textPrimary,
              onTap: () {},
            ),
            ContextMenuItemData(
              title: 'Unpin',
              icon: Assets.icons.unpin16,
              color: AppColors.textPrimary,
              onTap: () {},
            ),
            ContextMenuItemData(
              title: 'Save',
              icon: Assets.icons.download16,
              color: AppColors.textPrimary,
              onTap: () {},
            ),
            ContextMenuItemData(
              title: 'Save all (8)',
              icon: Assets.icons.download16,
              color: AppColors.textPrimary,
              onTap: () {},
            ),
            ContextMenuItemData(
              title: 'Delete',
              icon: Assets.icons.delete16,
              color: AppColors.iconNegative,
              onTap: () {},
            ),
          ],
          builder: (BuildContext context, bool contextMenuShown) {
            return message.map(
              text: (TextMessage textMessage) {
                if (textMessage.images.isNotEmpty) {
                  if (textMessage.text != null) {
                    return _TextWithMediaMessageView(
                      message: textMessage,
                      contextMenuShown: contextMenuShown,
                    );
                  } else {
                    return MediaMessageView(
                      message: textMessage,
                      contextMenuShown: contextMenuShown,
                    );
                  }
                } else {
                  return TextMessageView(
                    key: Key('TextMessageView${message.id}'),
                    textMessage: textMessage,
                    contextMenuShown: contextMenuShown,
                  );
                }
              },
              audio: (AudioMessage audioMessage) {
                return AudioMessageView(
                  audioMessage: audioMessage,
                  key: Key(audioMessage.url),
                );
              },
              // TODO: add file
              file: (_) => const SizedBox(),
            );
          },
        ),
      ),
    );
  }
}

class _MessageAligner extends StatelessWidget {
  const _MessageAligner({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Align(
          alignment: Alignment.centerRight,
          child: child,
        ),
      ),
    );
  }
}
