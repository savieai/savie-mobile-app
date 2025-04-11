part of 'message_view.dart';

class AudioMessageView extends StatefulWidget {
  const AudioMessageView({
    super.key,
    required this.audioMessage,
    required this.contextMenuShown,
  });

  final AudioMessage audioMessage;
  final bool contextMenuShown;

  @override
  State<AudioMessageView> createState() => _AudioMessageViewState();
}

class _AudioMessageViewState extends State<AudioMessageView> {
  double? _audioViewWidth;

  @override
  Widget build(BuildContext context) {
    final MessageCubit messageCubit = context.read<MessageCubit>();

    final bool isTranscribing = context.select(
      (ChatCubit cubit) => cubit.state.maybeMap(
        fetched: (ChatFetched value) => value.transcribingAudioMessageIds
            .contains(widget.audioMessage.currentId),
        orElse: () => false,
      ),
    );

    final bool isAudioTranscriptionExpanded = context.select(
      (MessageCubit cubit) => cubit.state.isAudioTranscriptionExpanded,
    );

    final bool isTranscriptionFailed = widget.audioMessage.transcriptionFailed;

    final bool hasTranscription = widget.audioMessage.transcription != null;

    return _MessageContainer(
      animateSize: false,
      padding: EdgeInsets.all(AppSpaces.space300),
      child: LayoutBuilder(builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final TextSpan transcriptionSpan = TextSpan(
          text: widget.audioMessage.transcription?.trim() ?? '',
          style: AppTextStyles.paragraph,
        );

        final TextPainter transcriptionPainter = TextPainter(
          text: transcriptionSpan,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        );

        final Size transcriptionSize =
            (transcriptionPainter..layout(maxWidth: constraints.maxWidth)).size;

        final TextSpan errorSpan = TextSpan(
          text: 'Something went wrong while\nprocessing the audio.',
          style: AppTextStyles.footnote.copyWith(
            color: AppColors.textSecondary,
          ),
        );

        final TextPainter errorPainter = TextPainter(
          text: errorSpan,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        );

        final Size errorSize =
            (errorPainter..layout(maxWidth: constraints.maxWidth)).size;

        final Size textSize =
            isTranscriptionFailed ? errorSize : transcriptionSize;
        final TextSpan textSpan =
            isTranscriptionFailed ? errorSpan : transcriptionSpan;

        final Duration animationDuration = isAudioTranscriptionExpanded
            ? Duration(milliseconds: 200 + textSize.width.toInt() ~/ 1.5)
            : Duration(milliseconds: 300 + textSize.width.toInt() ~/ 1.5);
        final Curve animationCurve = isAudioTranscriptionExpanded
            ? Curves.linearToEaseOut
            : Curves.easeOut;

        return AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          constraints: BoxConstraints(
            minWidth: isAudioTranscriptionExpanded && hasTranscription ||
                    isTranscriptionFailed
                ? textSize.width
                : 0,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Builder(
                        builder: (BuildContext context) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _audioViewWidth ??=
                                (context.findRenderObject()! as RenderBox)
                                    .size
                                    .width;
                          });

                          return AudioView(
                            audioMessage: widget.audioMessage,
                            expand: false,
                            previewInfo: false,
                            width: max(constraints.minWidth, 150),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _TranscriptionButton(
                        isTranscribing: isTranscribing,
                        isExpanded: isAudioTranscriptionExpanded,
                        isTranscriptionFailed: isTranscriptionFailed,
                        hasTranscription: hasTranscription,
                        onTap: widget.contextMenuShown
                            ? null
                            : () async {
                                if (isTranscribing) {
                                  return;
                                }

                                if (!hasTranscription) {
                                  final bool result = await context
                                      .read<ChatCubit>()
                                      .transcribeAudioMessage(
                                          widget.audioMessage);

                                  if (result && !isAudioTranscriptionExpanded) {
                                    messageCubit
                                        .toggleAudioTranscriptionExpansion();
                                  }
                                } else {
                                  setState(() {
                                    messageCubit
                                        .toggleAudioTranscriptionExpansion();
                                  });
                                }
                              },
                      ),
                    ],
                  ),
                  SizedBox(
                    width: max(constraints.minWidth, 150),
                    child: ClipRect(
                      child: AnimatedOpacity(
                        duration: animationDuration,
                        curve: isAudioTranscriptionExpanded ||
                                isTranscriptionFailed
                            ? Curves.easeIn
                            : Curves.easeOutCubic,
                        opacity: isAudioTranscriptionExpanded ||
                                isTranscriptionFailed
                            ? 1
                            : 0,
                        child: AnimatedContainer(
                          alignment: Alignment.bottomRight,
                          margin: EdgeInsets.only(
                            top: isAudioTranscriptionExpanded ||
                                    isTranscriptionFailed
                                ? 12
                                : 0,
                          ),
                          duration: animationDuration,
                          curve: Curves.linearToEaseOut,
                          width: isAudioTranscriptionExpanded ||
                                  isTranscriptionFailed
                              ? textSize.width
                              : 0,
                          height: isAudioTranscriptionExpanded ||
                                  isTranscriptionFailed
                              ? textSize.height
                              : 0,
                          child: OverflowBox(
                            alignment: Alignment.bottomLeft,
                            minHeight: textSize.height,
                            minWidth: textSize.width,
                            maxWidth: textSize.width,
                            maxHeight: textSize.height,
                            child: isTranscriptionFailed
                                ? Text.rich(textSpan)
                                : AnimatedSlide(
                                    offset: isAudioTranscriptionExpanded
                                        ? Offset.zero
                                        : const Offset(0, 1.5),
                                    curve: animationCurve,
                                    duration: animationDuration,
                                    child: Text.rich(textSpan),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}

class AudioView extends StatefulWidget {
  const AudioView({
    super.key,
    required this.audioMessage,
    required this.expand,
    required this.previewInfo,
    required this.width,
  });

  final AudioMessage audioMessage;
  final bool expand;
  final bool previewInfo;
  final double width;

  @override
  State<AudioView> createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> {
  late final Duration _totalDuration = widget.audioMessage.audioInfo.duration;
  late Duration _currentDuration;
  bool _isPlaying = false;
  late List<double>? _peeks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final PlayerState state = context.read<PlayerCubit>().state;
    _updateVariables(state);
  }

  void _updateVariables(PlayerState state) {
    if (state.audio?.audioInfo.name == widget.audioMessage.audioInfo.name) {
      _currentDuration = state.audio!.duration;
      _isPlaying = state.audio!.isPlaying;
    } else {
      _isPlaying = false;
      _currentDuration = Duration.zero;
    }
  }

  void _calculatePeeksIfNeeded(double width) {
    final int peeksLength = (width - 40 - 15 - AppSpaces.space400 * 2) ~/ 4;
    _peeks = resample(widget.audioMessage.audioInfo.peaks, peeksLength);
  }

  @override
  Widget build(BuildContext context) {
    _calculatePeeksIfNeeded(widget.width);

    final Widget waveForms = SizedBox(
      width: (widget.width - 40 - 15 - AppSpaces.space400 * 2) - 4,
      child: AnimatedSize(
        curve: Curves.linearToEaseOut,
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: max(0, (4 * (_peeks?.length ?? 0).toDouble()) - 2),
          height: 12,
          child: ListView.separated(
            itemCount: _peeks!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return FractionallySizedBox(
                heightFactor: max(_peeks![index], 0.1),
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: AppColors.bgChatTimelineInactive,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 2);
            },
          ),
        ),
      ),
    );

    return BlocListener<PlayerCubit, PlayerState>(
      listener: (BuildContext context, PlayerState state) {
        setState(() => _updateVariables(state));
      },
      listenWhen: (_, PlayerState current) =>
          current.audio?.audioInfo.messageId ==
          widget.audioMessage.audioInfo.messageId,
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              context
                  .read<PlayerCubit>()
                  .toggleAudio(widget.audioMessage.audioInfo);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: AppColors.iconAccent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: StreamBuilder<(double?, File?)>(
                stream: getIt
                    .get<GetFileStreamUseCase>()
                    .execute(name: widget.audioMessage.audioInfo.name),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<(double?, File?)> snapshot,
                ) {
                  final File? file = snapshot.data?.$2;
                  final double? progress = snapshot.data?.$1;
                  final bool hasData = snapshot.hasData;

                  final Widget child;

                  if (!hasData || file != null) {
                    child = SizedBox(
                      key: const Key('play_button'),
                      child: _isPlaying
                          ? Assets.icons.pause16.svg()
                          : Assets.icons.play20.svg(),
                    );
                  } else {
                    child = CustomPercentIndicator(progress: progress);
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: child,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: widget.expand ? 1 : 0,
            child: widget.previewInfo && !_isPlaying
                ? SizedBox(
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${DateFormat(DateFormat.YEAR_MONTH_DAY).format(widget.audioMessage.date)} at ${DateFormat.Hm().format(widget.audioMessage.date)}',
                          style: AppTextStyles.callout.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatDuration(_totalDuration),
                          style: AppTextStyles.callout.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 2),
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            waveForms,
                            Positioned.fill(
                              child: FractionallySizedBox(
                                widthFactor: (_currentDuration.inMilliseconds /
                                        _totalDuration.inMilliseconds)
                                    .clamp(0, 1),
                                alignment: Alignment.centerLeft,
                                child: ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.iconAccent,
                                    BlendMode.srcATop,
                                  ),
                                  child: waveForms,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (!widget.previewInfo || _isPlaying) ...<Widget>[
                          const SizedBox(width: 7),
                          Text(
                            formatDuration(
                              _isPlaying ? _currentDuration : _totalDuration,
                            ),
                            style: AppTextStyles.callout.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '$minutes:${twoDigits(seconds)}';
    }
  }

  List<double> resample(List<double> list, int newLength) {
    if (list.isEmpty || newLength <= 0) {
      return <double>[];
    }

    if (list.length == 1 || newLength == 1) {
      return List<double>.filled(newLength, list.first);
    }

    final List<double> result = <double>[];
    final double scale = (list.length - 1) / (newLength - 1);

    for (int i = 0; i < newLength; i++) {
      final double index = i * scale;
      final int leftIndex = index.floor();
      final int rightIndex = index.ceil();

      if (leftIndex == rightIndex) {
        result.add(list[leftIndex]);
      } else {
        final double t = index - leftIndex;
        final double interpolated =
            list[leftIndex] * (1 - t) + list[rightIndex] * t;
        result.add(interpolated);
      }
    }

    return result;
  }
}

class _TranscriptionButton extends StatelessWidget {
  const _TranscriptionButton({
    required this.isTranscribing,
    required this.isTranscriptionFailed,
    required this.hasTranscription,
    required this.isExpanded,
    required this.onTap,
  });

  final bool isTranscribing;
  final bool isTranscriptionFailed;
  final bool hasTranscription;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.backgroundChatAccentMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isTranscribing
            ? const _LoadingIndicator()
            : isTranscriptionFailed
                ? Assets.icons.arrowRotateLeftRight.svg()
                : !hasTranscription
                    ? Assets.icons.titleCase.svg()
                    : AnimatedRotation(
                        turns: isExpanded ? 0 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linearToEaseOut,
                        child: Assets.icons.chevronTopSmall.svg(),
                      ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2.5,
                color: AppColors.iconAccent.withValues(
                  alpha: 0.3,
                ),
                strokeAlign: 0,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
            width: 15,
            child: FittedBox(
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: AppColors.iconAccent,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
