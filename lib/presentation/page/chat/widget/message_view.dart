import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/domain.dart';
import '../../../cubit/player_cubit/player_cubit.dart';
import '../../../presentation.dart';
import '../../../router/app_router.gr.dart';

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
            builder: (
              BuildContext context,
              ContextMenuState contextMenuState,
            ) =>
                message.mediaPaths.isNotEmpty
                    ? message.text?.isNotEmpty ?? false
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 216 +
                                      (message.mediaPaths.length != 1
                                          ? 32
                                          : 0) -
                                      18,
                                ),
                                child: OverflowBox(
                                  maxHeight: double.infinity,
                                  fit: OverflowBoxFit.deferToChild,
                                  child: MediaMessageView(
                                    message: message,
                                    menuContextShown: contextMenuState ==
                                        ContextMenuState.shown,
                                  ),
                                ),
                              ),
                              if (message.text?.isNotEmpty ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child:
                                      TextMessageView(text: message.text ?? ''),
                                )
                              else
                                const SizedBox(height: 18)
                            ],
                          )
                        : MediaMessageView(
                            message: message,
                            menuContextShown:
                                contextMenuState == ContextMenuState.shown,
                          )
                    : message.audioMessage != null
                        ? AudioMessageView(
                            audioMessage: message.audioMessage!,
                            key: Key(message.audioMessage!.path),
                          )
                        : TextMessageView(text: message.text ?? ''),
          ),
        ),
      ),
    );
  }
}

class MediaMessageView extends StatelessWidget {
  const MediaMessageView({
    super.key,
    required this.message,
    required this.menuContextShown,
  });

  final Message message;
  final bool menuContextShown;

  String get heroTag => shownMediaPaths.first + message.id;

  List<String> get shownMediaPaths =>
      message.mediaPaths.take(4).toList().reversed.toList();

  @override
  Widget build(BuildContext context) {
    final List<String> shownMediaPaths =
        message.mediaPaths.take(4).toList().reversed.toList();
    final List<String> leftMediaPaths = shownMediaPaths.length >= 4
        ? message.mediaPaths.toList().sublist(4)
        : <String>[];

    return GestureDetector(
      onTap: () {
        context.router.push(
          PhotoCarouselRoute(message: message),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (message.mediaPaths.length != 1) ...<Widget>[
            _ImageCountLabel(
              count: message.mediaPaths.length,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                ...shownMediaPaths.mapIndexed(
                  (int index, String path) {
                    final Widget image = Image.file(
                      key: ValueKey<String>(path),
                      File(path),
                      fit: BoxFit.cover,
                    );

                    final Widget child = Container(
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
                      child: image,
                    );

                    final bool isMain = shownMediaPaths.length - index - 1 == 0;

                    return Padding(
                      padding: EdgeInsets.only(right: index * 8),
                      child: Transform.rotate(
                        angle: pi /
                            180 *
                            (shownMediaPaths.length - index - 1) *
                            1.5,
                        alignment: const Alignment(-0.5, 1),
                        child: Transform.scale(
                          scale:
                              1 - (shownMediaPaths.length - index - 1) * 0.05,
                          child: menuContextShown
                              ? child
                              : Hero(
                                  tag: path + message.id,
                                  flightShuttleBuilder: isMain
                                      // ignore: always_specify_types
                                      ? (p1, p2, p3, p4, p5) {
                                          return _flightShuttleBilder(
                                              p1, p2, p3, p4, p5,
                                              child: child);
                                        }
                                      : null,
                                  placeholderBuilder: (
                                    _,
                                    Size size,
                                    Widget child,
                                  ) {
                                    return isMain
                                        ? SizedBox(
                                            height: size.height,
                                            width: size.width,
                                          )
                                        : child;
                                  },
                                  child: child,
                                ),
                        ),
                      ),
                    );
                  },
                ),
                if (!menuContextShown)
                  ...leftMediaPaths.map((String path) {
                    return Hero(
                      tag: path + message.id,
                      child: const SizedBox(),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flightShuttleBilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext, {
    required Widget child,
  }) {
    return BlocBuilder<ChatInsetsCubit, EdgeInsets>(
      builder: (BuildContext context, EdgeInsets chatInsets) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, _) {
            final RenderBox? renderBox =
                flightContext.findRenderObject() as RenderBox?;

            if (renderBox != null) {
              final RenderBox? renderBox =
                  flightContext.findRenderObject() as RenderBox?;

              if (renderBox != null) {
                final Offset offset = renderBox.localToGlobal(Offset.zero);

                final double top = offset.dy;
                final double maxTop = chatInsets.top;

                final double bottom = offset.dy + renderBox.size.height;
                final double maxBottom =
                    MediaQuery.sizeOf(context).height - chatInsets.bottom;

                return ClipRect(
                  clipper: TopBottomClipper(
                    (maxTop - top) * (1 - animation.value),
                    (bottom - maxBottom) * (1 - animation.value),
                  ),
                  child: child,
                );
              }
            }

            return child;
          },
        );
      },
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

class AudioMessageView extends StatelessWidget {
  const AudioMessageView({
    super.key,
    required this.audioMessage,
  });

  final AudioMessage audioMessage;

  @override
  Widget build(BuildContext context) {
    return _MessageContainer(
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
  late final Duration _totalDuration = Duration(
    seconds: widget.audioMessage.seconds,
  );
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
    if (state.audio?.audioPath == widget.audioMessage.path) {
      _currentDuration = state.audio!.duration;
      _isPlaying = state.audio!.isPlaying;
    } else {
      _isPlaying = false;
      _currentDuration = Duration.zero;
    }
  }

  void _calculatePeeksIfNeeded(double maxWidth) {
    if (_peeks == null) {
      if (widget.expand) {
        final int peeksLength = maxWidth ~/ 4;
        _peeks = resample(widget.audioMessage.peeks, peeksLength);
      } else {
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
          current.audio?.audioPath == widget.audioMessage.path,
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
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
          Expanded(
            flex: widget.expand ? 1 : 0,
            child: widget.previewInfo
                ? SizedBox(
                    height: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'June 14, 2024 at 20:21',
                          style: AppTextStyles.callout.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '0:44',
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
          if (!widget.previewInfo) ...<Widget>[
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
