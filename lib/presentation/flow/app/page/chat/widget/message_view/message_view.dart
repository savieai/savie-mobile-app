import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
part 'file_message_view.dart';

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
                  return MessagePendingWrapper(
                    isPending: message.isPending,
                    child: TextMessageView(
                      key: Key('TextMessageView${message.id}'),
                      textMessage: textMessage,
                      contextMenuShown: contextMenuShown,
                    ),
                  );
                }
              },
              audio: (AudioMessage audioMessage) {
                return MessagePendingWrapper(
                  isPending: message.isPending,
                  child: AudioMessageView(
                    audioMessage: audioMessage,
                    key: Key(audioMessage.name),
                  ),
                );
              },
              file: (FileMessage fileMessage) => MessagePendingWrapper(
                isPending: message.isPending,
                child: FileMessageView(
                  fileMessage: fileMessage,
                ),
              ),
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

enum _MessagePendingWrapperState {
  pending,
  success,
  none,
}

class MessagePendingWrapper extends StatefulWidget {
  const MessagePendingWrapper({
    super.key,
    required this.isPending,
    required this.child,
  });

  final bool isPending;
  final Widget child;

  @override
  State<MessagePendingWrapper> createState() => _PendingWrapperState();
}

class _PendingWrapperState extends State<MessagePendingWrapper> {
  late _MessagePendingWrapperState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.isPending
        ? _MessagePendingWrapperState.pending
        : _MessagePendingWrapperState.none;
  }

  @override
  void didUpdateWidget(covariant MessagePendingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPending && !widget.isPending) {
      setState(() {
        _state = _MessagePendingWrapperState.success;
      });

      Future<void>.delayed(const Duration(milliseconds: 750), () {
        _state = _MessagePendingWrapperState.none;
        if (mounted && context.mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        widget.child,
        AnimatedScale(
          scale: _state == _MessagePendingWrapperState.none ? 0.25 : 1,
          duration: const Duration(milliseconds: 250),
          child: AnimatedOpacity(
            opacity: _state == _MessagePendingWrapperState.none ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: Transform.translate(
              offset: const Offset(4, -4),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: AppColors.backgroundChatBubble,
                  border: Border.all(
                    color: AppColors.strokePrimaryAlpha,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _state == _MessagePendingWrapperState.pending
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  alignment: Alignment.center,
                  firstChild: const Padding(
                    padding: EdgeInsets.all(4),
                    child: CircularProgressIndicator(
                      color: AppColors.textSecondary,
                      strokeWidth: 1.5,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  secondChild: Assets.icons.done16.svg(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
