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
  late TextMessage _textMessage = widget.textMessage;

  @override
  void didUpdateWidget(covariant TextMessageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textMessage != oldWidget.textMessage) {
      setState(() {
        _textMessage = widget.textMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TextContent> textContents =
        _textMessage.textContents ?? <TextContent>[];
    final String plainText =
        Document.fromDelta(TextContent.toDelta(textContents)).toPlainText();

    final List<Link> links = _textMessage.links;
    final List<InlineSpan> spans = _processTextContents(textContents);

    final bool linkOnly = plainText.trim() == links.firstOrNull?.url.trim();

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
      child: GestureDetector(
        child: SelectableText.rich(
          TextSpan(
            children: linkOnly
                ? _processLinks(links.first.url, addFavicon: true)
                : spans,
          ),
          enableInteractiveSelection: widget.contextMenuShown,
          cursorWidth: 0,
          style: AppTextStyles.paragraph.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
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

  List<InlineSpan> _processTextContents(List<TextContent> textContents) {
    final List<InlineSpan> spans = <InlineSpan>[];

    for (int i = 0; i < textContents.length; i++) {
      final TextContent content = textContents[i];

      if (content is PlainTextContent) {
        // Process plain text
        spans.addAll(_processLinks(content.text));
      } else if (content is ListItemContent) {
        // Process list items
        spans.addAll(<InlineSpan>[
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                final List<TextContent> newContents = textContents.toList();
                newContents[i] = content.copyWith(
                  isChecked: !content.isChecked,
                );
                context.read<ChatCubit>().editMessage(
                      textMessage: _textMessage,
                      textContents: newContents,
                      refetch: false,
                    );
                setState(() {
                  _textMessage = _textMessage.copyWith(
                    textContents: newContents,
                  );
                });
              },
              child: Container(
                height: 20,
                width: 20,
                alignment: Alignment.center,
                child: content.isChecked
                    ? Assets.icons.toDoSelected.svg()
                    : Assets.icons.toDo.svg(),
              ),
            ),
          ),
          const WidgetSpan(child: SizedBox(width: 6)),
        ]);

        spans.addAll(
          _processLinks('${content.text}\n').map(
            (InlineSpan span) {
              if (span is TextSpan) {
                // Apply line-through style for checked items
                return TextSpan(
                  text: span.text,
                  style: (span.style ?? const TextStyle()).copyWith(
                    decoration:
                        content.isChecked ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textTertiary,
                    color: content.isChecked ? AppColors.textTertiary : null,
                  ),
                );
              }
              return span;
            },
          ),
        );
      }
    }

    // Trim any trailing text spans
    if (spans.isNotEmpty && spans.last is TextSpan) {
      final TextSpan lastSpan = spans.last as TextSpan;
      spans.last = TextSpan(
        text: lastSpan.text?.trimRight(),
        style: lastSpan.style,
      );
    }

    return spans;
  }

  List<InlineSpan> _processLinks(String text, {bool addFavicon = false}) {
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
                alignment: PlaceholderAlignment.middle,
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
                          messageId: _textMessage.id,
                          type: _textMessage.appEventMessageType,
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
      // placeholder: (_, __) => Assets.icons.link16.svg(
      //   colorFilter: const ColorFilter.mode(
      //     AppColors.iconAccent,
      //     BlendMode.srcIn,
      //   ),
      // ),
      errorWidget: (_, __, ___) => Assets.icons.link16.svg(
        colorFilter: const ColorFilter.mode(
          AppColors.iconAccent,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
