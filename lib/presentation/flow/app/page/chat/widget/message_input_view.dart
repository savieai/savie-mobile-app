import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:wave_blob/wave_blob.dart';

import '../../../../../../application/application.dart';
import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../chat_page_provider.dart';
import 'message_view/sent_animation_text.dart';
import 'widget.dart';

class MessageInputView extends StatefulWidget {
  const MessageInputView({
    super.key,
  });

  @override
  State<MessageInputView> createState() => _MessageInputViewState();
}

class _MessageInputViewState extends State<MessageInputView> {
  final ValueNotifier<bool> _canRecordNotifier = ValueNotifier<bool>(true);
  final FocusNode _textFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.backgroundChatInput,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            _TextInputView(
              canRecordNotifier: _canRecordNotifier,
              focusNode: _textFocusNode,
            ),
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: _canRecordNotifier,
                builder: (BuildContext context, bool canRecord, _) {
                  return _AudioInputView(
                    canRecord: canRecord,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  const SendButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Assets.icons.arrowUp24.svg(
          colorFilter: const ColorFilter.mode(
            AppColors.iconAccent,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _TextInputView extends StatefulWidget {
  const _TextInputView({
    required this.canRecordNotifier,
    required this.focusNode,
  });

  final ValueNotifier<bool> canRecordNotifier;
  final FocusNode focusNode;

  @override
  State<_TextInputView> createState() => _TextInputViewState();
}

class _TextInputViewState extends State<_TextInputView> {
  final TextEditingController _controller = TextEditingController();
  ChatPagePorvider get _chatPagePorvider => ChatPagePorvider.of(context);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (widget.canRecordNotifier.value != _controller.text.isEmpty) {
        widget.canRecordNotifier.value = _controller.text.isEmpty;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _textForAnimation = '';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AnimationStatus>(
      valueListenable: _chatPagePorvider.sentMessageAnimationStatusNotifier,
      builder: (BuildContext context, AnimationStatus value, Widget? child) {
        return AnimatedSize(
          duration: value == AnimationStatus.forward
              ? ChatPagePorvider.sentMessageAnimationDuration
              : const Duration(milliseconds: 1),
          curve: Curves.linearToEaseOut,
          child: child,
        );
      },
      child: SizedBox(
        child: Row(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
              child: FilePickerButton(),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _chatPagePorvider.sentMessageAnimation,
                    builder: (BuildContext context, Widget? child) {
                      final double animationValue =
                          _chatPagePorvider.sentMessageAnimation.value;
                      return Positioned(
                        bottom: animationValue * 89 - 14,
                        left: -17,
                        right: -44,
                        child: Opacity(
                          opacity: animationValue == 0 ? 0 : 1,
                          child: Container(
                            alignment: Alignment(-1 + 2 * animationValue, -1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 20,
                            ),
                            child: SentAnimationText(
                              text: _textForAnimation,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  DefaultTextHeightBehavior(
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    child: CupertinoTextField(
                      focusNode: widget.focusNode,
                      controller: _controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 20),
                      autofocus: true,
                      minLines: 1,
                      maxLines: 5,
                      cursorColor: AppColors.iconAccent,
                      decoration: const BoxDecoration(),
                      style: AppTextStyles.paragraph,
                      placeholderStyle: AppTextStyles.paragraph.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      placeholder: 'Share anything...',
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.canRecordNotifier,
                builder: (BuildContext context, bool canRecord, _) {
                  return AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: canRecord
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: SendButton(
                      onTap: _onSend,
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Assets.icons.mic24.svg(
                        colorFilter: const ColorFilter.mode(
                          AppColors.iconSecodary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onSend() {
    context.read<ChatCubit>().sendMessage(text: _controller.text);
    _textForAnimation = _controller.text;

    if (ChatPagePorvider.of(context).canRunSentMessageAnimation) {
      ChatPagePorvider.of(context).runSentMessageAnimation();
    }
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.chat.sendButtonClicked);

    _controller.value = TextEditingValue.empty;
  }
}

class _AudioInputView extends StatefulWidget {
  const _AudioInputView({
    required this.canRecord,
  });

  final bool canRecord;

  @override
  State<_AudioInputView> createState() => _AudioInputViewState();
}

class _AudioInputViewState extends State<_AudioInputView>
    with TickerProviderStateMixin {
  late final AnimationController _horizontalSwipeAnimationController;
  late final Animation<double> _horizontalSwipeAnimation;

  late final AnimationController _verticalSwipeAnimationController;
  late final Animation<double> _verticalSwipeAnimation;

  late final AnimationController _completeAnimationController;
  late final Animation<double> _completeAnimation;

  late final AnimationController _scaleAnimationController;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _buttonOpacityAnimationController;
  late final Animation<double> _buttonOpacityAnimation;

  late final AnimationController _backgroundOpacityAnimationController;
  late final Animation<double> _backgroundOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _horizontalSwipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _horizontalSwipeAnimation = CurvedAnimation(
      parent: _horizontalSwipeAnimationController,
      curve: Curves.easeIn,
    );

    _verticalSwipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _verticalSwipeAnimation = CurvedAnimation(
      parent: _verticalSwipeAnimationController,
      curve: Curves.easeIn,
    );

    _completeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _completeAnimation = CurvedAnimation(
      parent: _completeAnimationController,
      curve: Curves.decelerate,
    );

    _scaleAnimationController = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 700),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.decelerate,
    );

    _buttonOpacityAnimationController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _buttonOpacityAnimation = CurvedAnimation(
      parent: _buttonOpacityAnimationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.decelerate,
    );

    _backgroundOpacityAnimationController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 400),
    );

    _backgroundOpacityAnimation = CurvedAnimation(
      parent: _buttonOpacityAnimationController,
      curve: Curves.linearToEaseOut,
    );
  }

  @override
  void dispose() {
    _horizontalSwipeAnimationController.dispose();
    _verticalSwipeAnimationController.dispose();
    _completeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _buttonOpacityAnimationController.dispose();
    super.dispose();
  }

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.canRecord) {
      return const SizedBox();
    }

    return BlocConsumer<RecordingCubit, RecordingState>(
      listener: (BuildContext context, RecordingState state) {
        final bool isRecording =
            state.mapOrNull(recording: (_) => true) ?? false;

        if (!isVisible && isRecording) {
          setState(() {
            isVisible = true;
          });
        }

        if (isRecording) {
          _backgroundOpacityAnimationController.forward();
        } else {
          _backgroundOpacityAnimationController.reverse().then((_) {
            setState(() {
              isVisible = false;
            });
          });
        }
      },
      listenWhen: (RecordingState previous, RecordingState current) =>
          previous.runtimeType != current.runtimeType,
      builder: (BuildContext context, RecordingState state) {
        final bool isRecording =
            state.mapOrNull(recording: (_) => true) ?? false;

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Visibility(
              visible: isVisible,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: AnimatedBuilder(
                        animation: _backgroundOpacityAnimation,
                        builder: (BuildContext context, _) {
                          return Opacity(
                            opacity: _backgroundOpacityAnimation.value,
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                color: AppColors.backgroundChatInput,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isRecording)
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      alignment: Alignment.centerLeft,
                      child: const _ElapsedTime(),
                    ),
                  if (isRecording)
                    AnimatedCrossFade(
                        alignment: Alignment.center,
                        firstChild: Container(
                          alignment: const Alignment(0.35, 0),
                          child: _SwipeToCancel(
                            swipeAnimation: _horizontalSwipeAnimation,
                          ),
                        ),
                        secondChild: const Center(child: _CanecelButton()),
                        crossFadeState: state.isFixed
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                        layoutBuilder: (
                          Widget topChild,
                          Key topKey,
                          Widget bottomChild,
                          Key bottomKey,
                        ) {
                          return Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Positioned.fill(
                                key: topKey,
                                child: Center(child: bottomChild),
                              ),
                              Positioned(
                                key: bottomKey,
                                child: topChild,
                              ),
                            ],
                          );
                        }),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _verticalSwipeAnimation,
              builder: (BuildContext context, Widget? child) {
                final double bottomOffset = (state.isRecording ? 84 : 0);

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  bottom: bottomOffset,
                  right: 0,
                  left: 0,
                  top: -bottomOffset,
                  child: Transform.translate(
                    offset: Offset(0, -_verticalSwipeAnimation.value * 15),
                    child: child,
                  ),
                );
              },
              child: AnimatedOpacity(
                opacity: state.isRecording && !state.isFixed ? 1 : 0,
                curve: Curves.linearToEaseOut,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 11),
                  child: const OverflowBox(
                    maxHeight: 66,
                    alignment: Alignment.centerRight,
                    child: _RecordingFixLabel(),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: Listenable.merge(<Listenable?>[
                  _buttonOpacityAnimation,
                  _completeAnimation,
                  _scaleAnimation,
                  _buttonOpacityAnimation,
                  _verticalSwipeAnimation,
                ]),
                builder: (BuildContext context, Widget? child) {
                  final double dx = (-_horizontalSwipeAnimation.value +
                          _completeAnimation.value) *
                      80;

                  final double dy = (-_verticalSwipeAnimation.value) * 40;

                  final double scale =
                      (1 - _horizontalSwipeAnimation.value) * 0.4 +
                          _scaleAnimation.value * 0.6;

                  return Opacity(
                    opacity: _buttonOpacityAnimation.value,
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 64,
                  width: 64,
                  alignment: Alignment.center,
                  child: OverflowBox(
                    maxWidth: 200,
                    maxHeight: 200,
                    child: _ActiveRecordingButton(
                      scaleAnimationController: _scaleAnimationController,
                      horizontalSwipeAnimationController:
                          _horizontalSwipeAnimationController,
                      completeAnimationController: _completeAnimationController,
                      opacityAnimationController:
                          _buttonOpacityAnimationController,
                      verticalSwipeAnimationController:
                          _verticalSwipeAnimationController,
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

class _ActiveRecordingButton extends StatelessWidget {
  const _ActiveRecordingButton({
    required this.horizontalSwipeAnimationController,
    required this.completeAnimationController,
    required this.scaleAnimationController,
    required this.opacityAnimationController,
    required this.verticalSwipeAnimationController,
  });

  final AnimationController horizontalSwipeAnimationController;
  final AnimationController completeAnimationController;
  final AnimationController scaleAnimationController;
  final AnimationController opacityAnimationController;
  final AnimationController verticalSwipeAnimationController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecordingCubit, RecordingState>(
      listener: _recordingFixListener,
      listenWhen: (RecordingState previous, RecordingState current) =>
          previous.isFixed != current.isFixed,
      child: BlocConsumer<RecordingCubit, RecordingState>(
        listener: _mainListener,
        listenWhen: (RecordingState previous, RecordingState current) =>
            previous.isRecording != current.isRecording,
        builder: (BuildContext context, RecordingState state) {
          final bool isRecording =
              state.mapOrNull(recording: (_) => true) ?? false;

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: List<Widget>.generate(3, (int index) {
                  final double size = 90 + 10 * index.toDouble();

                  return SizedBox.square(
                    dimension: size,
                    child: WaveBlob(
                      scale: 1 + state.peek * (0.6 + index / 20),
                      autoScale: false,
                      speed: 1,
                      amplitude: 6000,
                      blobCount: 1,
                      centerCircle: false,
                      colors: <Color>[
                        AppColors.backgroundChatVoice.withOpacity(0.1),
                        AppColors.backgroundChatVoice.withOpacity(0.1),
                      ],
                      child: SizedBox.square(dimension: size),
                    ),
                  );
                }),
              ),
              XGestureDetector(
                onLongPress: (_) {
                  if (context.read<RecordingCubit>().state.isFixed) {
                    return;
                  }

                  getIt
                      .get<TrackUseActivityUseCase>()
                      .execute(AppEvents.chat.voiceButtonClicked);
                  context.read<RecordingCubit>().startRecording();
                },
                longPressTimeConsider: 100,
                behavior: isRecording
                    ? HitTestBehavior.translucent
                    : HitTestBehavior.opaque,
                onLongPressEnd: completeAnimationController.isAnimating
                    ? null
                    : () => _onLongPressEnd(context),
                onLongPressMove: completeAnimationController.isAnimating
                    ? null
                    : (MoveEvent details) =>
                        _onLongPressMoveUpdate(context, details),
                onTap: state.isFixed ? (_) => _onFinish(context) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  height: 60 * (1 + state.peek * 0.3),
                  width: 60 * (1 + state.peek * 0.3),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundChatVoice,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Assets.icons.arrowUp24.svg(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _mainListener(BuildContext context, RecordingState state) {
    state.when(
      idle: (RecordingResult result) {
        if (result == RecordingResult.cancel) {
          opacityAnimationController.reverse();
          verticalSwipeAnimationController.reverse();
          if (horizontalSwipeAnimationController.value != 0) {
            completeAnimationController.forward().then((_) {
              completeAnimationController.value = 0;
              horizontalSwipeAnimationController.value = 0;
            });
          }
          scaleAnimationController.reverse().then((_) {
            scaleAnimationController.value = 1;
          });
        } else if (result == RecordingResult.finish ||
            result == RecordingResult.none) {
          opacityAnimationController.reverse();
          scaleAnimationController.forward();
          horizontalSwipeAnimationController.reverse();
        }

        verticalSwipeAnimationController.reverse();
      },
      recording: (_, __, ___, ____) {
        HapticFeedback.lightImpact();
        opacityAnimationController.forward();
      },
    );
  }

  void _recordingFixListener(BuildContext context, RecordingState state) {
    final bool isFixed = state.isFixed;

    if (isFixed) {
      verticalSwipeAnimationController.reverse();
    }
  }

  Future<void> _onCancel(BuildContext context) async {
    // TODO: specify duration
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.chat.voiceCancelClicked(duration: Duration.zero));
    await context.read<RecordingCubit>().cancelRecording();
  }

  Future<void> _onFinish(BuildContext context) async {
    final AudioInfo? audioInfo =
        await context.read<RecordingCubit>().finishRecording();
    // TODO: specify duration
    getIt
        .get<TrackUseActivityUseCase>()
        .execute(AppEvents.chat.voiceButtonReleased(duration: Duration.zero));

    if (context.mounted) {
      context.read<ChatCubit>().sendAudio(audioInfo);
    }
  }

  Future<void> _onLongPressEnd(BuildContext context) async {
    if (!context.read<RecordingCubit>().state.isRecording) {
      return;
    }

    if (horizontalSwipeAnimationController.value > 0.5) {
      return _onCancel(context);
    } else if (!context.read<RecordingCubit>().state.isFixed) {
      return _onFinish(context);
    } else {
      scaleAnimationController.forward();
      horizontalSwipeAnimationController.reverse();
    }
  }

  Future<void> _onLongPressMoveUpdate(
    BuildContext context,
    MoveEvent details,
  ) async {
    if (!context.read<RecordingCubit>().state.isRecording ||
        context.read<RecordingCubit>().state.isFixed) {
      return;
    }

    final double newHorizonatalValue =
        (-details.localPos.dx / 2).clamp(0, 80) / 80;
    horizontalSwipeAnimationController.value = newHorizonatalValue;

    final double newVerticalValue =
        (-details.localPos.dy / 2).clamp(0, 60) / 60;
    verticalSwipeAnimationController.value = newVerticalValue;

    if (newVerticalValue == 1) {
      HapticFeedback.lightImpact();
      // TODO: specify duraiton
      getIt
          .get<TrackUseActivityUseCase>()
          .execute(AppEvents.chat.voiceLocked(duration: Duration.zero));
      context.read<RecordingCubit>().fixRecording();
    }

    if (newHorizonatalValue == 1) {
      return _onCancel(context);
    }
  }
}

class _ElapsedTime extends StatefulWidget {
  const _ElapsedTime();

  @override
  State<_ElapsedTime> createState() => _ElapsedTimeState();
}

class _ElapsedTimeState extends State<_ElapsedTime> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Assets.icons.rec16.svg(
            colorFilter: const ColorFilter.mode(
              AppColors.iconNegative,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<RecordingCubit, RecordingState>(
            builder: (BuildContext context, RecordingState state) {
              return Text(
                _formatDuration(Duration(seconds: state.seconds)),
                style: AppTextStyles.callout.copyWith(
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final String negativeSign = duration.isNegative ? '-' : '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes =
        twoDigits(duration.inMinutes.remainder(60).abs());
    final String twoDigitSeconds =
        twoDigits(duration.inSeconds.remainder(60).abs());
    return '$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}

class _CanecelButton extends StatelessWidget {
  const _CanecelButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        context.read<RecordingCubit>().cancelRecording();
      },
      child: Text(
        'Cancel',
        style: AppTextStyles.paragraph.copyWith(
          color: AppColors.iconNegative,
          height: 1,
        ),
      ),
    );
  }
}

class _SwipeToCancel extends StatefulWidget {
  const _SwipeToCancel({
    required this.swipeAnimation,
  });

  final Animation<double> swipeAnimation;

  @override
  State<_SwipeToCancel> createState() => _SwipeToCancelState();
}

class _SwipeToCancelState extends State<_SwipeToCancel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _animationController.forward();
    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable?>[
        _animation,
        widget.swipeAnimation,
      ]),
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: (1 - widget.swipeAnimation.value).clamp(0, 0.7) / 0.7,
          child: Transform.translate(
            offset: Offset(_animation.value * -20, 0) +
                Offset(widget.swipeAnimation.value * -40, 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Assets.icons.chevronLeft16.svg(
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Slide to cancel',
              style: AppTextStyles.callout.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingFixLabel extends StatelessWidget {
  const _RecordingFixLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundChatBubble,
        border: Border.all(
          color: AppColors.strokeSecondaryAlpha,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color: AppColors.strokeSecondaryAlpha,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Assets.icons.unlocked24.svg(),
          const SizedBox(height: 4),
          Assets.icons.chevronUp16.svg(),
        ],
      ),
    );
  }
}
