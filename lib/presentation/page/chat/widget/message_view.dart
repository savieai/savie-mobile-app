import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/domain.dart';
import '../../../cubit/player_cubit/player_cubit.dart';
import '../../../presentation.dart';

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: Align(
          alignment: Alignment.centerRight,
          child: message.mediaPaths.isNotEmpty
              ? MediaMessageView(mediaPaths: message.mediaPaths)
              : message.audioMessage != null
                  ? AudioMessageView(
                      audioMessage: message.audioMessage!,
                      key: Key(message.audioMessage!.path),
                    )
                  : TextMessageView(text: message.text ?? ''),
        ),
      ),
    );
  }
}

class MediaMessageView extends StatelessWidget {
  const MediaMessageView({
    super.key,
    required this.mediaPaths,
  });

  final List<String> mediaPaths;

  @override
  Widget build(BuildContext context) {
    final List<String> shownMediaPaths = mediaPaths.reversed.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (mediaPaths.length != 1) ...<Widget>[
          _ImageCountLabel(
            count: mediaPaths.length,
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              ...shownMediaPaths.mapIndexed(
                (int index, String path) {
                  return Padding(
                    padding: EdgeInsets.only(right: index * 8),
                    child: Transform.rotate(
                      angle:
                          pi / 180 * (shownMediaPaths.length - index - 1) * 1.5,
                      alignment: const Alignment(-0.5, 1),
                      child: Transform.scale(
                        scale: 1 - (shownMediaPaths.length - index - 1) * 0.05,
                        child: Container(
                          height: 216,
                          width: 180,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                color: Colors.black.withOpacity(0.16),
                              ),
                            ],
                          ),
                          child: Image.file(
                            key: ValueKey<String>(path),
                            File(path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageCountLabel extends StatelessWidget {
  const _ImageCountLabel({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Assets.icons.stack16.svg(
            colorFilter: const ColorFilter.mode(
              AppColors.iconAccent,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count images',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.iconAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class AudioMessageView extends StatefulWidget {
  const AudioMessageView({
    super.key,
    required this.audioMessage,
  });

  final AudioMessage audioMessage;

  @override
  State<AudioMessageView> createState() => _AudioMessageViewState();
}

class _AudioMessageViewState extends State<AudioMessageView> {
  late final Duration _totalDuration = Duration(
    seconds: widget.audioMessage.seconds,
  );
  Duration _currentDuration = Duration.zero;
  bool _isPlaying = false;
  List<double>? _peeks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_peeks == null) {
      final int projectedPeeksLength =
          (widget.audioMessage.seconds * 2).clamp(10, 60);
      final double maxSpace =
          (MediaQuery.sizeOf(context).width - 20 * 2) * 0.8 - 67 - 80;
      // TODO: calculate text instead of 80;
      final int maxPeeksLength = maxSpace ~/ 4;
      final int acutalPeeksLength = min(maxPeeksLength, projectedPeeksLength);
      _peeks = resample(widget.audioMessage.peeks, acutalPeeksLength);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget waveForms = SizedBox(
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

    return BlocListener<PlayerCubit, PlayerState>(
      listener: (BuildContext context, PlayerState state) {
        if (state.audio?.audioPath == widget.audioMessage.path) {
          setState(() {
            _currentDuration = state.audio!.duration;
            _isPlaying = state.audio!.isPlaying;
          });
        }
      },
      child: _MessageContainer(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () =>
                  context.read<PlayerCubit>().toggleAudio(widget.audioMessage),
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundChatVoice,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: _isPlaying
                    ? Assets.icons.pause16.svg()
                    : Assets.icons.play20.svg(),
              ),
            ),
            const SizedBox(width: 11),
            Stack(
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
        ),
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

    return result;
  }
}

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return _MessageContainer(
      child: Text(
        text,
        style: AppTextStyles.paragraph.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MessageContainer extends StatelessWidget {
  const _MessageContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundChatBubble,
        border: Border.all(
          color: AppColors.strokeSecondaryAlpha,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color: AppColors.strokeSecondaryAlpha,
          ),
        ],
      ),
      child: child,
    );
  }
}
