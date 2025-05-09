import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../../application/application.dart';
import '../../../../../../../domain/domain.dart';
import '../../../../../../presentation.dart';
import '../../../../../../router/app_router.gr.dart';
import '../../../common/widget/fav_icon.dart';
import '../../chat_page_provider.dart';
import '../../cubit/cubit.dart';
import '../widget.dart';
import 'pending_task_view.dart';
import '../../../../../../../infrastructure/mapper/message_mapper.dart';

part 'media_message_view.dart';
part 'audio_message_view.dart';
part 'text_message_view.dart';
part 'message_container.dart';
part 'text_with_media_message_view.dart';
part 'file_message_view.dart';

class MessageView extends StatefulWidget {
  const MessageView({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  late final MessageCubit _messageCubit;

  @override
  void initState() {
    _messageCubit = MessageCubit(message: widget.message);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MessageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _messageCubit.updateMessage(widget.message);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MessageCubit>(
      create: (_) => MessageCubit(message: widget.message),
      child: Column(
        children: <Widget>[
          MessageTimeWrapper(
            time: widget.message.date,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _MessageAligner(
                  child: ContextMenuRegion(
                    heroTag: '${widget.message.currentId}_context_menu',
                    data: _getContextMenuData(context),
                    builder: (
                      BuildContext context,
                      Animation<double> animtion,
                      bool contextMenuShown,
                    ) {
                      return BlocProvider<MessageCubit>.value(
                        value: _messageCubit,
                        child: widget.message.map(
                          text: (TextMessage textMessage) {
                            if (textMessage.images.isNotEmpty) {
                              if (textMessage.currentPlainText != null) {
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
                                isPending: widget.message.isPending,
                                isNew: widget.message.isNew,
                                child: TextMessageView(
                                  textMessage: textMessage,
                                  contextMenuShown: contextMenuShown,
                                ),
                              );
                            }
                          },
                          audio: (AudioMessage audioMessage) {
                            return MessagePendingWrapper(
                              isPending: widget.message.isPending,
                              isNew: widget.message.isNew,
                              child: AudioMessageView(
                                audioMessage: audioMessage,
                                contextMenuShown: contextMenuShown,
                              ),
                            );
                          },
                          file: (FileMessage fileMessage) =>
                              MessagePendingWrapper(
                            isPending: widget.message.isPending,
                            isNew: widget.message.isNew,
                            child: FileMessageView(
                              fileMessage: fileMessage,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.message is TextMessage)
                  PendingTaskView(
                    textMessage: widget.message as TextMessage,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ContextMenuItemData> _getContextMenuData(BuildContext context) {
    return <ContextMenuItemData>[
      ...widget.message.map(
        text: (TextMessage textMessage) {
          late final bool hasChatPageCubit;

          try {
            context.read<ChatPageCubit>();
            hasChatPageCubit = true;
          } catch (_) {
            hasChatPageCubit = false;
          }

          return <ContextMenuItemData>[
            if ((textMessage.currentPlainText ?? '')
                .isNotEmpty) ...<ContextMenuItemData>[
              if (!widget.message.isPending && hasChatPageCubit)
                ContextMenuItemData(
                  title: 'Edit',
                  icon: Assets.icons.edit16,
                  color: AppColors.textPrimary,
                  onTap: () {
                    context
                        .read<ChatPageCubit>()
                        .setEditingMessage(textMessage);
                  },
                ),
              ContextMenuItemData(
                title: 'Copy',
                icon: Assets.icons.copy16,
                color: AppColors.textPrimary,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: textMessage.currentPlainText ?? ''),
                  );
                },
              ),
            ],
            if (textMessage.images.isNotEmpty && !Platform.isMacOS)
              if (textMessage.images.length == 1)
                ContextMenuItemData(
                  title: 'Save',
                  icon: Assets.icons.download16,
                  color: AppColors.textPrimary,
                  onTap: () {
                    getIt.get<SaveImagesUseCase>().execute(textMessage.images);
                  },
                )
              else
                ContextMenuItemData(
                  title: 'Save all (${textMessage.images.length})',
                  icon: Assets.icons.download16,
                  color: AppColors.textPrimary,
                  onTap: () {
                    getIt.get<SaveImagesUseCase>().execute(textMessage.images);
                  },
                ),
            ContextMenuItemData(
              title: 'Share',
              icon: Assets.icons.share16,
              color: AppColors.textPrimary,
              onTap: () {
                getIt.get<ShareFilesUseCase>().execute(
                      textMessage.images,
                      plainText: textMessage.currentPlainText,
                    );
              },
            ),
            if (textMessage.improvedTextContents == null)
              ContextMenuItemData(
                title: 'Improve Text',
                icon: Assets.icons.listSparkle,
                color: AppColors.textPrimary,
                onTap: () {
                  Future<void>.delayed(const Duration(milliseconds: 350), () {
                    if (context.mounted) {
                      context.read<ChatCubit>().improveText(textMessage);
                    }
                  });
                },
              ),
            if (textMessage.improvedTextContents !=
                null) ...<ContextMenuItemData>[
              ContextMenuItemData(
                title: 'Revert to original',
                icon: Assets.icons.revert,
                color: AppColors.textPrimary,
                onTap: () {
                  Future<void>.delayed(const Duration(milliseconds: 350), () {
                    if (context.mounted) {
                      context
                          .read<ChatCubit>()
                          .undoTextImprovement(textMessage);
                    }
                  });
                },
              )
            ],
          ];
        },
        audio: (AudioMessage audioMessage) {
          return <ContextMenuItemData>[
            ContextMenuItemData(
              title: 'Share',
              icon: Assets.icons.share16,
              color: AppColors.textPrimary,
              onTap: () {
                getIt.get<ShareFilesUseCase>().execute(<Attachment>[
                  Attachment(
                    name: audioMessage.audioInfo.name,
                    remoteStorageName: audioMessage.audioInfo.name,
                    signedUrl: audioMessage.audioInfo.signedUrl,
                    localFullPath: audioMessage.audioInfo.localFullPath,
                    placeholderUrl: null,
                  ),
                ]);
              },
            ),
          ];
        },
        file: (FileMessage fileMessage) {
          return <ContextMenuItemData>[
            ContextMenuItemData(
              title: 'Share',
              icon: Assets.icons.share16,
              color: AppColors.textPrimary,
              onTap: () {
                getIt.get<ShareFilesUseCase>().execute(<Attachment>[
                  fileMessage.file,
                ]);
              },
            ),
          ];
        },
      ),
      if (!widget.message.isPending)
        ContextMenuItemData(
          title: 'Delete',
          icon: Assets.icons.delete16,
          color: AppColors.iconNegative,
          onTap: () {
            Future<void>.delayed(const Duration(milliseconds: 250), () {
              if (context.mounted) {
                context
                    .read<ChatCubit>()
                    .deleteMessage(messageId: widget.message.id);
              }
            });
          },
        ),
    ];
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
        widthFactor: Platform.isMacOS ? 0.8 : 0.9,
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
    required this.isNew,
    required this.child,
  });

  final bool isPending;
  final bool isNew;
  final Widget child;

  @override
  State<MessagePendingWrapper> createState() => _PendingWrapperState();
}

class _PendingWrapperState extends State<MessagePendingWrapper>
    with SingleTickerProviderStateMixin {
  late _MessagePendingWrapperState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.isPending
        ? _MessagePendingWrapperState.pending
        : _MessagePendingWrapperState.none;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (Scrollable.maybeOf(context) == null) {
      return;
    }
  }

  @override
  void didUpdateWidget(covariant MessagePendingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPending) {
      _state = _MessagePendingWrapperState.pending;
    }

    if (oldWidget.isPending && !widget.isPending) {
      setState(() {
        _state = _MessagePendingWrapperState.success;
      });

      Future<void>.delayed(const Duration(milliseconds: 900), () {
        _state = _MessagePendingWrapperState.none;
        if (mounted && context.mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AnimationStatus>(
      valueListenable: ChatPagePorvider.maybeOf(context)
              ?.sentMessageAnimationStatusNotifier ??
          ValueNotifier<AnimationStatus>(AnimationStatus.dismissed),
      builder: (BuildContext context, AnimationStatus value, Widget? child) {
        return Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            Opacity(
              opacity: widget.isNew && value == AnimationStatus.forward ? 0 : 1,
              child: widget.child,
            ),
            AnimatedOpacity(
              opacity: widget.isNew && value == AnimationStatus.forward ? 0 : 1,
              duration: const Duration(milliseconds: 100),
              child: AnimatedScale(
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
                        duration: const Duration(milliseconds: 450),
                        crossFadeState:
                            _state == _MessagePendingWrapperState.pending
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                        alignment: Alignment.center,
                        layoutBuilder:
                            (Widget topChild, _, Widget bottomChild, __) {
                          return Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              bottomChild,
                              topChild,
                            ],
                          );
                        },
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
            ),
          ],
        );
      },
    );
  }
}
