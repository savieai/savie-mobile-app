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
    final bool isImproving = context.select(
      (ChatCubit cubit) => cubit.state.maybeMap(
        fetched: (ChatFetched value) =>
            value.improvingTextMessageIds.contains(_textMessage.currentId),
        orElse: () => false,
      ),
    );
    final bool improvementFailed = _textMessage.improvementFailed;
    final List<TextContent>? improvedTextContents =
        _textMessage.improvedTextContents;

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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _SelectableMessageText currentText = _SelectableMessageText(
            textContentsToDisplay: widget.textMessage.improvedTextContents ??
                widget.textMessage.originalTextContents ??
                <TextContent>[],
            contextMenuShown: widget.contextMenuShown,
            textMessage: widget.textMessage,
            onMessageChanged: (TextMessage updatedMessage) {
              // TODO: think on editing
              context.read<ChatCubit>().editMessage(
                    textMessage: _textMessage,
                    textContents:
                        updatedMessage.originalTextContents ?? <TextContent>[],
                    refetch: false,
                  );
              setState(() => _textMessage = updatedMessage);
            },
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              currentText,
              if (_textMessage.tasks.isNotEmpty)
                _MessageTasks(
                  tasks: _textMessage.tasks,
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.linearToEaseOut,
                alignment: Alignment.topLeft,
                child: _ImprovingView(
                  minSize: currentText.getSize(context, constraints).width,
                  isImproving: isImproving,
                  oldTextContents: _textMessage.originalTextContents,
                  improvementFailed: improvementFailed,
                  isImproved: improvedTextContents != null,
                  textMessage: _textMessage,
                  onRetry: () {
                    context.read<ChatCubit>().improveText(widget.textMessage);
                  },
                  contextMenuShown: widget.contextMenuShown,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectableMessageText extends StatefulWidget {
  const _SelectableMessageText({
    required this.textContentsToDisplay,
    required this.contextMenuShown,
    required this.textMessage,
    required this.onMessageChanged,
  });

  final List<TextContent> textContentsToDisplay;
  final bool contextMenuShown;
  final TextMessage textMessage;
  final ValueChanged<TextMessage> onMessageChanged;

  TextSpan getTextSpan() {
    final String plainText =
        Document.fromDelta(TextContent.toDelta(textContentsToDisplay))
            .toPlainText();

    final List<InlineSpan> spans =
        _SelectableMessageTextState._processTextContents(
      textContentsToDisplay,
      onMessageChanged,
      textMessage,
    );

    final bool linkOnly =
        plainText.trim() == textMessage.links.firstOrNull?.url.trim();

    final TextSpan textSpan = TextSpan(
      children: linkOnly
          ? _SelectableMessageTextState._processLinks(
              textMessage.links.first.url,
              addFavicon: true,
              message: textMessage,
            )
          : spans,
    );

    return textSpan;
  }

  Size getSize(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    late final Size textSize;

    try {
      textSize = (TextPainter(
        text: getTextSpan(),
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: constraints.maxWidth - AppSpaces.space300 * 2))
          .size;
    } catch (_) {
      textSize = Size.zero;
    }

    return textSize;
  }

  @override
  State<_SelectableMessageText> createState() => _SelectableMessageTextState();
}

class _SelectableMessageTextState extends State<_SelectableMessageText> {
  late TextMessage _textMessage = widget.textMessage;

  @override
  void didUpdateWidget(covariant _SelectableMessageText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textMessage != oldWidget.textMessage) {
      setState(() {
        _textMessage = widget.textMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String plainText =
        Document.fromDelta(TextContent.toDelta(widget.textContentsToDisplay))
            .toPlainText();

    final List<InlineSpan> spans = _processTextContents(
      widget.textContentsToDisplay,
      widget.onMessageChanged,
      widget.textMessage,
    );

    final bool linkOnly =
        plainText.trim() == _textMessage.links.firstOrNull?.url.trim();

    final TextSpan textSpan = TextSpan(
      children: linkOnly
          ? _processLinks(
              _textMessage.links.first.url,
              addFavicon: true,
              message: widget.textMessage,
            )
          : spans,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SelectableText.rich(
          textSpan,
          enableInteractiveSelection: widget.contextMenuShown,
          cursorWidth: 0,
          style: AppTextStyles.paragraph.copyWith(
            color: AppColors.textPrimary,
          ),
        );
      },
    );
  }

  static List<InlineSpan> _processTextContents(
    List<TextContent> textContents,
    ValueChanged<TextMessage> onMessageChanged,
    TextMessage textMessage,
  ) {
    final List<InlineSpan> spans = <InlineSpan>[];

    for (int i = 0; i < textContents.length; i++) {
      final TextContent content = textContents[i];

      if (content is PlainTextContent) {
        // Process plain text
        spans.addAll(_processLinks(content.text, message: textMessage));
      } else if (content is ListItemContent) {
        // Process list items
        spans.addAll(<InlineSpan>[
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                // TODO: think on editing
                final List<TextContent> newContents = textContents.toList();
                newContents[i] = content.copyWith(
                  isChecked: !content.isChecked,
                );
                final TextMessage updatedMessage = textMessage.copyWith(
                  originalTextContents: newContents,
                );
                onMessageChanged(updatedMessage);
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
          _processLinks('${content.text}\n', message: textMessage).map(
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

  static List<InlineSpan> _processLinks(
    String text, {
    required TextMessage message,
    bool addFavicon = false,
  }) {
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
                          messageId: message.id,
                          type: message.appEventMessageType,
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

  static String _completeLink(String url) {
    if (!url.startsWith(RegExp(r'https?://'))) {
      return 'http://$url';
    }
    return url;
  }

  static final RegExp _linkRegExp = RegExp(
    r'\b(?:(?:https?)://)?(?:www\.)?(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}(?:/[^\s]*)?\b',
    caseSensitive: false,
  );
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

class _ImprovingView extends StatefulWidget {
  const _ImprovingView({
    required this.isImproving,
    required this.textMessage,
    required this.oldTextContents,
    required this.isImproved,
    required this.improvementFailed,
    required this.onRetry,
    required this.minSize,
    required this.contextMenuShown,
  });

  final bool isImproving;
  final TextMessage textMessage;
  final List<TextContent>? oldTextContents;
  final bool isImproved;
  final bool improvementFailed;
  final VoidCallback onRetry;
  final double minSize;
  final bool contextMenuShown;

  @override
  State<_ImprovingView> createState() => _ImprovingViewState();
}

class _ImprovingViewState extends State<_ImprovingView> {
  bool _justImproved = false;

  @override
  void didUpdateWidget(covariant _ImprovingView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isImproved && !oldWidget.isImproved) {
      setState(() {
        _justImproved = true;
      });

      Future<void>.delayed(const Duration(seconds: 2), () {
        setState(() {
          _justImproved = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _justImproved
          ? const _TextHasBeenImproved()
          : widget.isImproving
              ? const _ImprovingText()
              : widget.improvementFailed
                  ? _RetryImproving(onRetry: widget.onRetry)
                  : widget.isImproved
                      ? _OriginalText(
                          textMessage: widget.textMessage,
                          oldTextContents: widget.oldTextContents,
                          minSize: widget.minSize,
                          contextMenuShown: widget.contextMenuShown,
                        )
                      : const SizedBox(),
    );
  }
}

class _RetryImproving extends StatelessWidget {
  const _RetryImproving({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            WidgetSpan(
              child: Assets.icons.triangleExclamation.svg(),
              alignment: PlaceholderAlignment.middle,
            ),
            const TextSpan(text: ' Oops! I couldn’t improve this one. '),
            TextSpan(
              text: 'Retry',
              recognizer: TapGestureRecognizer()..onTap = onRetry,
              style: const TextStyle(
                color: AppColors.iconAccent,
              ),
            ),
          ],
        ),
        style: AppTextStyles.footnote.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ImprovingText extends StatelessWidget {
  const _ImprovingText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Stack(
              children: <Widget>[
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: const Color(0x4DAE9999),
                      strokeAlign: 0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                  width: 10,
                  child: FittedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: Color(0xFFAE9999),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Improving your text',
            style: AppTextStyles.footnote.copyWith(
              color: const Color(0xFFAE9999),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextHasBeenImproved extends StatelessWidget {
  const _TextHasBeenImproved();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Assets.icons.checkmark1.svg(height: 16, width: 16),
          const SizedBox(width: 6),
          Text(
            'Your text has been improved',
            style: AppTextStyles.footnote.copyWith(
              color: AppColors.textSuccess,
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginalText extends StatelessWidget {
  const _OriginalText({
    required this.textMessage,
    required this.oldTextContents,
    required this.minSize,
    required this.contextMenuShown,
  });

  final TextMessage textMessage;
  final List<TextContent>? oldTextContents;
  final double minSize;
  final bool contextMenuShown;

  @override
  Widget build(BuildContext context) {
    final double minSizeConstrained = max(minSize, 60);
    final bool isExpanded = context.select(
      (MessageCubit cubit) => cubit.state.isImprovedTextExpanded,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: contextMenuShown
                ? null
                : context.read<MessageCubit>().toggleImprovedTextExpansion,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedRotation(
                  turns: isExpanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.linearToEaseOut,
                  child:
                      Assets.icons.chevronTopSmall.svg(height: 16, width: 16),
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minSizeConstrained),
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.centerLeft,
                    firstChild: Text(
                      'Hide original',
                      style: AppTextStyles.footnote.copyWith(
                        color: AppColors.iconAccent,
                      ),
                    ),
                    secondChild: Text(
                      'Show original',
                      style: AppTextStyles.footnote.copyWith(
                        color: AppColors.iconAccent,
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 350),
            sizeCurve: Curves.linearToEaseOut,
            alignment: Alignment.centerLeft,
            firstChild: SizedBox(width: minSizeConstrained),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _SelectableMessageText(
                textContentsToDisplay: oldTextContents ?? <TextContent>[],
                contextMenuShown: contextMenuShown,
                textMessage: textMessage,
                onMessageChanged: (_) {},
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

class _MessageTasks extends StatelessWidget {
  const _MessageTasks({
    required this.tasks,
  });

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 4),
        for (final Task task in tasks) ...<Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Assets.icons.calendarCheck.svg(
                height: 16,
                width: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSuccess,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.textSuccess,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
