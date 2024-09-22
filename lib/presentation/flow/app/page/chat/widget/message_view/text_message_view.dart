part of 'message_view.dart';

class TextMessageView extends StatefulWidget {
  const TextMessageView({
    super.key,
    required this.textMessage,
    required this.contextMenuShown,
    this.enableSentMessageAinmation = false,
  });

  final TextMessage textMessage;
  final bool contextMenuShown;
  final bool enableSentMessageAinmation;

  @override
  State<TextMessageView> createState() => _TextMessageViewState();
}

class _TextMessageViewState extends State<TextMessageView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final String text = widget.textMessage.text ?? '';

    final List<Link> links = widget.textMessage.links;
    final List<InlineSpan> spans = _convertToSpans(text, false);

    final bool linkOnly = text == links.firstOrNull?.url;

    final Animation<double> sentMessageAnimation =
        widget.enableSentMessageAinmation
            ? ChatPagePorvider.of(context).sentMessageAnimation
            : const AlwaysStoppedAnimation<double>(1);

    return AnimatedBuilder(
      animation: sentMessageAnimation,
      builder: (BuildContext context, Widget? child) {
        return _MessageContainer(
          decorationOpacity: sentMessageAnimation.value,
          child: child!,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!linkOnly)
            SelectableText.rich(
              TextSpan(children: spans),
              enableInteractiveSelection: widget.contextMenuShown,
              cursorWidth: 0,
              style: AppTextStyles.paragraph.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          if (links.length == 1)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!linkOnly) const SizedBox(height: 6),
                SelectableText.rich(
                  TextSpan(children: _convertToSpans(links.first.url, true)),
                  enableInteractiveSelection: widget.contextMenuShown,
                  cursorWidth: 0,
                  style: AppTextStyles.paragraph.copyWith(
                    color: AppColors.textPrimary,
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  static final RegExp _linkRegExp = RegExp(
    r'\b(?:(?:https?)://)?(?:www\.)?(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}(?:/[^\s]*)?\b',
    caseSensitive: false,
  );

  static String _completeLink(String url) {
    if (!url.startsWith(RegExp(r'https?://'))) {
      return 'http://$url';
    }
    return url;
  }

  List<InlineSpan> _convertToSpans(String text, bool addFavicon) {
    final List<InlineSpan> spans = <InlineSpan>[];
    final List<RegExpMatch> matches = _linkRegExp.allMatches(text).toList();

    int lastMatchEnd = 0;
    for (final RegExpMatch match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      final String url = match.group(0)!;
      spans.add(
        TextSpan(
          children: <InlineSpan>[
            if (addFavicon)
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FavIcon(
                    key: Key('Favicon${_completeLink(url)}'),
                    completeLink: _completeLink(url),
                  ),
                ),
              ),
            TextSpan(
              text: url,
              style: const TextStyle(
                color: AppColors.iconAccent,
                overflow: TextOverflow.visible,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  getIt.get<TrackUseActivityUseCase>().execute(
                        AppEvents.chat.linkClicked(
                          messageId: widget.textMessage.id,
                          type: widget.textMessage.appEventMessageType,
                        ),
                      );
                  launchUrlString(_completeLink(url));
                },
            ),
          ],
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return spans;
  }
}

class FavIcon extends StatefulWidget {
  const FavIcon({
    super.key,
    required this.completeLink,
  });

  final String completeLink;

  @override
  State<FavIcon> createState() => _FavIconState();
}

class _FavIconState extends State<FavIcon> {
  String? _imageUrl;
  bool _isLoading = true;
  bool _noIcon = false;

  @override
  void initState() {
    super.initState();
    final String? syncUrl =
        getIt.get<GetFavIconUrlSyncUseCase>().execute(widget.completeLink);
    if (syncUrl != null) {
      _processFaviconUrl(syncUrl);
    } else {
      _loadFavicon();
    }
  }

  Future<void> _loadFavicon() async {
    final String? iconUrl =
        await getIt.get<GetFavIconUrlUseCase>().execute(widget.completeLink);

    _processFaviconUrl(iconUrl);
  }

  void _processFaviconUrl(String? iconUrl) {
    if (iconUrl == null) {
      setState(() {
        _isLoading = false;
        _noIcon = true;
      });
    } else {
      setState(() {
        _imageUrl = iconUrl;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 20,
        width: 20,
        alignment: Alignment.center,
        child: const SizedBox(
          height: 14,
          width: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            strokeCap: StrokeCap.round,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    if (_noIcon) {
      return Assets.icons.linkIcon.svg();
    }

    if (_imageUrl == null) {
      return const SizedBox();
    }

    return CachedNetworkImage(
      imageUrl: _imageUrl!,
      cacheKey: _imageUrl,
      height: 20,
      width: 20,
    );
  }
}
