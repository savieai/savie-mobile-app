part of 'message_view.dart';

class MediaMessageView extends StatelessWidget {
  const MediaMessageView({
    super.key,
    required this.message,
    required this.contextMenuShown,
  });

  final Message message;
  final bool contextMenuShown;

  String get heroTag => shownMediaPaths.first + message.id;

  List<String> get shownMediaPaths =>
      message.mediaPaths.take(4).toList().reversed.toList();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: contextMenuShown
          ? null
          : () {
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
            child: _ImageStack(
              contextMenuShown: contextMenuShown,
              message: message,
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
  final Message message;

  @override
  Widget build(BuildContext context) {
    final List<String> shownMediaPaths =
        message.mediaPaths.take(4).toList().reversed.toList();
    final List<String> leftMediaPaths = shownMediaPaths.length >= 4
        ? message.mediaPaths.toList().sublist(4)
        : <String>[];

    return Stack(
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
                angle: pi / 180 * (shownMediaPaths.length - index - 1) * 1.5,
                alignment: const Alignment(-0.5, 1),
                child: Transform.scale(
                  scale: 1 - (shownMediaPaths.length - index - 1) * 0.05,
                  child: contextMenuShown
                      ? child
                      : Hero(
                          tag: path + message.id,
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
          ...leftMediaPaths.map((String path) {
            return Hero(
              tag: path + message.id,
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
