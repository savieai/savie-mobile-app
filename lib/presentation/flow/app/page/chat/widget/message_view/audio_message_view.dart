part of 'message_view.dart';

class AudioMessageView extends StatelessWidget {
  const AudioMessageView({
    super.key,
    required this.audioMessage,
  });

  final AudioMessage audioMessage;

  @override
  Widget build(BuildContext context) {
    return _MessageContainer(
      animateSize: false,
      child: AudioView(
        audioMessage: audioMessage,
        expand: false,
        previewInfo: false,
      ),
    );
  }
}

class AudioView extends StatefulWidget {
  const AudioView({
    super.key,
    required this.audioMessage,
    required this.expand,
    required this.previewInfo,
  });

  final AudioMessage audioMessage;
  final bool expand;
  final bool previewInfo;

  @override
  State<AudioView> createState() => _AudioViewState();
}

class _AudioViewState extends State<AudioView> {
  late final Duration _totalDuration = widget.audioMessage.audioInfo.duration;
  late Duration _currentDuration;
  bool _isPlaying = false;
  List<double>? _peeks;

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

  double? _processedMaxWidth;
  void _calculatePeeksIfNeeded(double maxWidth) {
    if (_processedMaxWidth != maxWidth) {
      if (widget.expand) {
        final int peeksLength = maxWidth ~/ 4;
        _peeks = resample(widget.audioMessage.audioInfo.peaks, peeksLength);
      } else {
        final int projectedPeeksLength =
            (widget.audioMessage.audioInfo.duration.inSeconds * 2)
                .clamp(10, 60);
        final double maxSpace = (MediaQuery.sizeOf(context).width - 20 * 2) *
                (Platform.isMacOS ? 0.8 : 0.9) -
            67 -
            80;
        // TODO: calculate text instead of 80;
        final int maxPeeksLength = maxSpace ~/ 4;
        final int acutalPeeksLength = min(maxPeeksLength, projectedPeeksLength);
        _peeks =
            resample(widget.audioMessage.audioInfo.peaks, acutalPeeksLength);
      }

      _processedMaxWidth = maxWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget waveForms = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _calculatePeeksIfNeeded(constraints.maxWidth);
        return SizedBox(
          height: 20,
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
                    color: AppColors.voiceTint,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 2);
            },
          ),
        );
      },
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
                color: AppColors.backgroundChatVoice,
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
                        const SizedBox(height: 4),
                        Text(
                          formatDuration(_totalDuration),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
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
                              AppColors.backgroundChatVoice,
                              BlendMode.srcATop,
                            ),
                            child: waveForms,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (!widget.previewInfo || _isPlaying) ...<Widget>[
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.voiceTint,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                formatDuration(_totalDuration - _currentDuration),
                style: AppTextStyles.callout.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
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
    if (list.isEmpty) {
      return List<double>.generate(newLength, (_) => 0);
    }

    if (newLength < 0) {
      throw ArgumentError('newLength must be non-negative');
    }

    if (newLength == 0) {
      return List<double>.generate(newLength, (_) => 0);
    }

    final List<double> result = <double>[];
    final double factor = (list.length - 1) / (newLength - 1);

    for (int i = 0; i < newLength; i++) {
      final double index = i * factor;
      final int leftIndex = index.floor();
      final int rightIndex = index.ceil().clamp(0, newLength - 1);

      if (leftIndex == rightIndex) {
        result.add(list[leftIndex]);
      } else {
        final double leftValue = list[leftIndex];
        final double rightValue = list[rightIndex];
        final double interpolatedValue =
            leftValue + (rightValue - leftValue) * (index - leftIndex);
        result.add(interpolatedValue);
      }
    }

    final double max = result.max;

    if (max == 0) {
      return result;
    }

    return result.map((double e) => e / max).toList();
  }
}
