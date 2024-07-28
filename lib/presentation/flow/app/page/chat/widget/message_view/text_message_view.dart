part of 'message_view.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    super.key,
    required this.text,
    required this.contextMenuShown,
  });

  final String text;
  final bool contextMenuShown;

  @override
  Widget build(BuildContext context) {
    final List<String> links = _extractLinks(text);
    final List<InlineSpan> spans = _convertToSpans(text);

    return _MessageContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectableText.rich(
            TextSpan(children: spans),
            enableInteractiveSelection: contextMenuShown,
            cursorWidth: 0,
            style: AppTextStyles.paragraph.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (links.isNotEmpty)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 6),
                ...links.map(
                  (String link) => SelectableText.rich(
                    TextSpan(children: _convertToSpans(link)),
                    enableInteractiveSelection: contextMenuShown,
                    cursorWidth: 0,
                    style: AppTextStyles.paragraph.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
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

  List<String> _extractLinks(String text) {
    final Iterable<RegExpMatch> matches = _linkRegExp.allMatches(text);
    return matches.map((RegExpMatch match) => match.group(0)!).toList();
  }

  static String _completeLink(String url) {
    if (!url.startsWith(RegExp(r'https?://'))) {
      return 'http://$url';
    }
    return url;
  }

  List<InlineSpan> _convertToSpans(String text) {
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
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _FavIcon(
                  key: Key('Favicon$_completeLink(url)'),
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
                ..onTap = () => launchUrlString(_completeLink(url)),
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

// Global cache for storing favicon URLs and their image bytes
final Map<String, Uint8List?> _faviconCache = <String, Uint8List?>{};
final Map<String, bool> _isSvgMap = <String, bool>{};
final Map<String, String> _faviconUrls = <String, String>{};

class _FavIcon extends StatefulWidget {
  const _FavIcon({
    super.key,
    required this.completeLink,
  });

  final String completeLink;

  @override
  _FavIconState createState() => _FavIconState();
}

class _FavIconState extends State<_FavIcon> {
  Uint8List? _imageBytes;
  bool _isSvg = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavicon();
  }

  Future<void> _loadFavicon() async {
    // Check if the image bytes are already in the cache
    if (_faviconCache.containsKey(widget.completeLink)) {
      setState(() {
        _imageBytes = _faviconCache[widget.completeLink];
        _isSvg = _isSvgMap[widget.completeLink] ?? false;
        _isLoading = false;
      });
      return;
    }
    try {
      final String? url = await (_faviconUrls.containsKey(widget.completeLink)
          ? Future<String>.value(_faviconUrls[widget.completeLink]!)
          : FaviconFinder.getBest(widget.completeLink).then((Favicon? f) {
              return f?.url;
            })
        ..then((String? url) =>
            url == null ? null : _faviconUrls[widget.completeLink] = url));

      if (url != null) {
        final Response<dynamic> response = await Dio().get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );

        setState(() {
          final String? contentType = response.headers.value('content-type');

          _imageBytes = response.data as Uint8List?;
          _isLoading = false;
          // Cache the fetched image bytes
          if (_imageBytes != null) {
            _isSvg = contentType != null && contentType.contains('svg');
            _isSvgMap[widget.completeLink] = _isSvg;
            _faviconCache[widget.completeLink] = _imageBytes;
          }
        });
      } else {
        _faviconCache[widget.completeLink] = null;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _faviconCache[widget.completeLink] = null;
      setState(() {
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

    if (_imageBytes == null) {
      return const SizedBox();
    }

    if (_isSvg) {
      return SvgPicture.memory(
        _imageBytes!,
        height: 20,
        width: 20,
      );
    }

    return Image.memory(
      _imageBytes!,
      height: 20,
      width: 20,
    );
  }
}
