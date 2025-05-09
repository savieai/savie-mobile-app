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
        
    // Additional validation and fixing for improved text
    List<TextContent> fixedContents = _getFixedContents(_textMessage);

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
            textContentsToDisplay: fixedContents,
            target: _textMessage.textEditingTarget,
            contextMenuShown: widget.contextMenuShown,
            textMessage: _textMessage,
            isSecondary: false,
            onMessageChanged: (TextMessage updatedMessage) {
              context.read<ChatCubit>().editMessage(
                    textMessage: _textMessage,
                    textContents:
                        updatedMessage.currentTextContents ?? <TextContent>[],
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
                  minSize: currentText.getSize(context, constraints),
                  isImproving: isImproving,
                  oldTextContents: _textMessage.originalTextContents,
                  improvementFailed: improvementFailed,
                  isImproved: improvedTextContents != null && !isImproving,
                  textMessage: _textMessage,
                  onRetry: () {
                    context.read<ChatCubit>().improveText(_textMessage);
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
  
  // Helper method to ensure all items in a list are properly formatted
  List<TextContent> _getFixedContents(TextMessage message) {
    final List<TextContent>? contents = message.currentTextContents;
    if (contents == null || contents.isEmpty) {
      return <TextContent>[];
    }
    
    // Check if this is a to-do list
    bool hasList = false;
    for (final content in contents) {
      if (content is ListItemContent) {
        hasList = true;
        break;
      }
    }
    
    if (!hasList) {
      return contents;
    }
    
    // This is a to-do list, make sure all items are formatted as list items
    final fixedContents = <TextContent>[];
    bool lastWasList = false;
    
    for (int i = 0; i < contents.length; i++) {
      final content = contents[i];
      
      if (content is ListItemContent) {
        fixedContents.add(content);
        lastWasList = true;
      } else if (content is PlainTextContent) {
        // Skip empty content
        if (content.text.trim().isEmpty) {
          continue;
        }
        
        // If this is in the context of a list, convert to list item
        // Especially focus on the last item which is often problematic
        if ((lastWasList || i == contents.length - 1) && hasList) {
          // Convert to list item
          fixedContents.add(ListItemContent(
            text: content.text.replaceFirst(RegExp(r'\n$'), ''),
            isChecked: false,
          ));
          lastWasList = true;
        } else {
          fixedContents.add(content);
          lastWasList = false;
        }
      }
    }
    
    return fixedContents;
  }
}

class _SelectableMessageText extends StatefulWidget {
  const _SelectableMessageText({
    required this.textContentsToDisplay,
    required this.contextMenuShown,
    required this.textMessage,
    required this.target,
    required this.onMessageChanged,
    required this.isSecondary,
  });

  final List<TextContent> textContentsToDisplay;
  final bool contextMenuShown;
  final TextMessage textMessage;
  final TextEditingTarget target;
  final ValueChanged<TextMessage> onMessageChanged;
  final bool isSecondary;

  TextSpan getTextSpan() {
    final String plainText =
        Document.fromDelta(TextContent.toDelta(textContentsToDisplay))
            .toPlainText();

    final List<InlineSpan> spans =
        _SelectableMessageTextState._processTextContents(
      textContentsToDisplay,
      target,
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

    final TextSpan textSpan = getTextSpan();

    final int widgetSpanCount =
        (textSpan.children ?? <InlineSpan>[]).whereType<WidgetSpan>().length;

    final List<PlaceholderDimensions> dimensions =
        List<PlaceholderDimensions>.generate(widgetSpanCount, (_) {
      return const PlaceholderDimensions(
        size: Size(26, 20),
        alignment: PlaceholderAlignment.middle,
      );
    });

    try {
      textSize = (TextPainter(
        text: getTextSpan(),
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: TextDirection.ltr,
      )
            ..setPlaceholderDimensions(dimensions)
            ..layout(maxWidth: constraints.maxWidth - AppSpaces.space300 * 2))
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
        Document.fromDelta(_textMessage.content)
            .toPlainText();

    final List<InlineSpan> spans = _processTextContents(
      widget.textContentsToDisplay,
      widget.target,
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
          cursorWidth: widget.contextMenuShown ? 2 : 0,
          style: AppTextStyles.paragraph.copyWith(
            color: widget.isSecondary
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        );
      },
    );
  }

  static List<InlineSpan> _processTextContents(
    List<TextContent> textContents,
    TextEditingTarget target,
    ValueChanged<TextMessage> onMessageChanged,
    TextMessage textMessage,
  ) {
    final List<InlineSpan> spans = <InlineSpan>[];
    
    // Debug info for troubleshooting
    // print('Processing ${textContents.length} TextContent items');

    for (int i = 0; i < textContents.length; i++) {
      final TextContent content = textContents[i];

      if (content is PlainTextContent) {
        // Process plain text
        spans.addAll(_processLinks(content.text, message: textMessage));
      } else if (content is ListItemContent) {
        // Debug info
        // print('Processing ListItemContent: ${content.text}, isChecked: ${content.isChecked}');
        
        // Process list items - always add checkbox widget
        spans.addAll(<InlineSpan>[
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                final List<TextContent> newContents = textContents.toList();
                newContents[i] = content.copyWith(
                  isChecked: !content.isChecked,
                );

                final TextMessage updatedMessage = switch (target) {
                  TextEditingTarget.original => textMessage.copyWith(
                      originalTextContents: newContents,
                    ),
                  TextEditingTarget.enhanced => textMessage.copyWith(
                      improvedTextContents: newContents,
                    )
                };

                onMessageChanged(updatedMessage);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
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
          ),
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
  final Size minSize;
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
    } else if (oldWidget.isImproved && !widget.isImproved) {
      setState(() {
        _justImproved = false;
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
            const TextSpan(text: " Oops! I couldn't improve this one. "),
            TextSpan(
              text: "Retry",
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
  final Size minSize;
  final bool contextMenuShown;

  @override
  Widget build(BuildContext context) {
    final double minSizeConstrained = max(minSize.width, 60);

    final bool isExpanded = context.select(
      (MessageCubit cubit) => cubit.state.isImprovedTextExpanded,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final _SelectableMessageText oldText = _SelectableMessageText(
          textContentsToDisplay: oldTextContents ?? <TextContent>[],
          contextMenuShown: contextMenuShown,
          textMessage: textMessage,
          target: TextEditingTarget.original,
          onMessageChanged: (_) {},
          isSecondary: true,
        );
        final Size oldTextSize = oldText.getSize(context, constraints);

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
                      child: Assets.icons.chevronTopSmall
                          .svg(height: 16, width: 16),
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: minSizeConstrained - 20),
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
                alignment: Alignment.topLeft,
                firstChild: SizedBox(
                  width: max(oldTextSize.width + 20, minSizeConstrained),
                ),
                secondChild: Container(
                  padding: const EdgeInsets.only(top: 8),
                  child: oldText,
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
            ],
          ),
        );
      },
    );
  }
}
