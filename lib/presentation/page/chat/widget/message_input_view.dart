import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wave_blob/wave_blob.dart';

import '../../../../domain/domain.dart';
import '../../../presentation.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
  });

  final ValueNotifier<bool> canRecordNotifier;

  @override
  State<_TextInputView> createState() => _TextInputViewState();
}

class _TextInputViewState extends State<_TextInputView> {
  final TextEditingController _controller = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: DefaultTextHeightBehavior(
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        child: CupertinoTextField(
          controller: _controller,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          autofocus: true,
          minLines: 1,
          maxLines: 5,
          cursorColor: AppColors.iconAccent,
          prefix: const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
            child: FilePickerButton(),
          ),
          decoration: const BoxDecoration(),
          style: AppTextStyles.paragraph,
          placeholderStyle: AppTextStyles.paragraph.copyWith(
            color: AppColors.textSecondary,
          ),
          placeholder: 'Share anything...',
          textInputAction: TextInputAction.newline,
          suffix: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            child: ValueListenableBuilder<bool>(
              valueListenable: widget.canRecordNotifier,
              builder: (BuildContext context, bool canRecord, _) {
                return AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: canRecord
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: _SendButton(
                    onTap: () {
                      context.read<ChatCubit>().sendMessage(_controller.text);
                      _controller.value = TextEditingValue.empty;
                    },
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
          ),
        ),
      ),
    );
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
  late final AnimationController _swipeAnimationController;
  late final Animation<double> _swipeAnimation;

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

    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _swipeAnimation = CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeOutCubic,
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
    _swipeAnimationController.dispose();
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
                    Container(
                      alignment: const Alignment(0.35, 0),
                      child: _SwipeToCancel(
                        swipeAnimation: _swipeAnimation,
                      ),
                    ),
                ],
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
                ]),
                builder: (BuildContext context, Widget? child) {
                  final double dx =
                      (-_swipeAnimation.value + _completeAnimation.value) * 80;

                  final double scale = (1 - _swipeAnimation.value) * 0.4 +
                      _scaleAnimation.value * 0.6;

                  return Opacity(
                    opacity: _buttonOpacityAnimation.value,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
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
                      swipeAnimationController: _swipeAnimationController,
                      completeAnimationController: _completeAnimationController,
                      opacityAnimationController:
                          _buttonOpacityAnimationController,
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
    required this.swipeAnimationController,
    required this.completeAnimationController,
    required this.scaleAnimationController,
    required this.opacityAnimationController,
  });

  final AnimationController swipeAnimationController;
  final AnimationController completeAnimationController;
  final AnimationController scaleAnimationController;
  final AnimationController opacityAnimationController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordingCubit, RecordingState>(
      listener: (BuildContext context, RecordingState state) {
        final bool isRecording =
            state.mapOrNull(recording: (_) => true) ?? false;

        state.when(
          idle: (RecordingResult result) {
            if (result == RecordingResult.cancel) {
              opacityAnimationController.reverse();
              completeAnimationController.forward().then((_) {
                completeAnimationController.value = 0;
                swipeAnimationController.value = 0;
                scaleAnimationController.value = 1;
              });
              scaleAnimationController.reverse();
            } else if (result == RecordingResult.finish ||
                result == RecordingResult.none) {
              opacityAnimationController.reverse();
              scaleAnimationController.forward();
              swipeAnimationController.reverse();
            }
          },
          recording: (_, __, ___) => opacityAnimationController.forward(),
        );

        if (isRecording) {
          opacityAnimationController.forward();
        } else {}
      },
      listenWhen: (RecordingState previous, RecordingState current) =>
          previous.runtimeType != current.runtimeType,
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
            GestureDetector(
              behavior: isRecording
                  ? HitTestBehavior.translucent
                  : HitTestBehavior.opaque,
              onLongPressStart: (_) {
                context.read<RecordingCubit>().startRecording();
              },
              onTap: () {},
              onLongPressEnd: completeAnimationController.isAnimating
                  ? null
                  : (_) => _onLongPressEnd(context),
              onLongPressMoveUpdate: completeAnimationController.isAnimating
                  ? null
                  : (LongPressMoveUpdateDetails details) =>
                      _onLongPressMoveUpdate(context, details),
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
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    await context.read<RecordingCubit>().cancelRecording();
  }

  Future<void> _onFinish(BuildContext context) async {
    final AudioMessage? audioMessage =
        await context.read<RecordingCubit>().finishRecording();
    if (context.mounted) {
      context.read<ChatCubit>().sendAudio(audioMessage);
    }
  }

  Future<void> _onLongPressEnd(BuildContext context) async {
    if (!context.read<RecordingCubit>().state.isRecording) {
      return;
    }

    if (swipeAnimationController.value > 0.5) {
      return _onCancel(context);
    } else {
      return _onFinish(context);
    }
  }

  Future<void> _onLongPressMoveUpdate(
    BuildContext context,
    LongPressMoveUpdateDetails details,
  ) async {
    if (!context.read<RecordingCubit>().state.isRecording) {
      return;
    }

    final double newValue =
        (-details.offsetFromOrigin.dx / 2).clamp(0, 80) / 80;
    swipeAnimationController.value = newValue;

    if (newValue == 1) {
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
