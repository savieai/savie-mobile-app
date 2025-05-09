part of 'message_view.dart';

class MediaMessageView extends StatelessWidget {
  const MediaMessageView({
    super.key,
    required this.message,
    required this.contextMenuShown,
  });

  final TextMessage message;
  final bool contextMenuShown;

  List<Attachment> get shownMediaPaths =>
      message.images.take(4).toList().reversed.toList();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: contextMenuShown
          ? null
          : () {
              getIt.get<TrackUseActivityUseCase>().execute(
                    AppEvents.chat.attachmentClicked(
                      messageId: message.id,
                      type: message.appEventMessageType,
                    ),
                  );
              context.router.push(
                PhotoCarouselRoute(
                  images: message.images,
                  caption: message.currentPlainText,
                  initialBorderRadius: 20,
                  initialIndex: 0,
                  heroTagPredicate: (Attachment image) => '${image.name}_chat',
                ),
              );
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (message.images.length != 1) ...<Widget>[
            _ImageCountLabel(
              count: message.images.length,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: MessagePendingWrapper(
              isPending: message.isPending,
              isNew: message.isNew,
              child: _ImageStack(
                contextMenuShown: contextMenuShown,
                message: message,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageStack extends StatelessWidget {
  const _ImageStack({
    required this.contextMenuShown,
    required this.message,
  });

  final bool contextMenuShown;
  final TextMessage message;

  @override
  Widget build(BuildContext context) {
    final List<Attachment> shownMediaPaths =
        message.images.take(4).toList().reversed.toList();
    final List<Attachment> leftMediaPaths = shownMediaPaths.length >= 4
        ? message.images.toList().sublist(4)
        : <Attachment>[];

    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        ...shownMediaPaths.mapIndexed(
          (int index, Attachment attachment) {
            final Widget image = CustomImage(
              attachment: attachment,
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
                    color: Colors.black.withValues(alpha: 0.16),
                  ),
                ],
              ),
              child: image,
            );

            final bool isMain = shownMediaPaths.length - index - 1 == 0;

            return Padding(
              padding: EdgeInsets.only(right: index * 8),
              child: Transform.rotate(
                angle: pi / 180 * (shownMediaPaths.length - index - 1) * 1.5,
                alignment: const Alignment(-0.5, 1),
                child: Transform.scale(
                  scale: 1 - (shownMediaPaths.length - index - 1) * 0.05,
                  child: contextMenuShown
                      ? child
                      : Hero(
                          tag: '${attachment.name}_chat',
                          flightShuttleBuilder: isMain
                              // ignore: always_specify_types
                              ? (p1, p2, p3, p4, p5) {
                                  return _flightShuttleBilder(
                                    p1, p2, p3, p4, p5, //
                                    child: child,
                                  );
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
        if (!contextMenuShown)
          ...leftMediaPaths.map((Attachment attachment) {
            return Hero(
              tag: '${attachment.name}_chat',
              child: const SizedBox(),
            );
          }),
      ],
    );
  }
}

Widget _flightShuttleBilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext, {
  required Widget child,
}) {
  final BuildContext pageContext = flightDirection == HeroFlightDirection.push
      ? fromHeroContext
      : toHeroContext;

  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, _) {
      final Size contextMenuVisibleSize = HeroVisibleArea.sizeOf(pageContext);
      final Offset contextMenuVisiblePosition =
          HeroVisibleArea.positionOf(pageContext);

      final RenderBox? renderBox =
          flightContext.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final RenderBox? renderBox =
            flightContext.findRenderObject() as RenderBox?;

        if (renderBox != null) {
          final Offset offset = renderBox.localToGlobal(Offset.zero);

          final double top = offset.dy;
          final double maxTop = contextMenuVisiblePosition.dy;

          final double bottom = offset.dy + renderBox.size.height;
          final double maxBottom = maxTop + contextMenuVisibleSize.height;

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
