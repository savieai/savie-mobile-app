import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../../../../domain/domain.dart';
import '../../../../../../presentation.dart';
import '../../chat_page_provider.dart';
import 'message_view.dart';

class SentAnimationText extends StatefulWidget {
  const SentAnimationText({
    super.key,
    required this.textContents,
  });

  final List<TextContent> textContents;

  @override
  State<SentAnimationText> createState() => _SentAnimationTextState();
}

class _SentAnimationTextState extends State<SentAnimationText> {
  late final Size textSize;
  bool _textSizeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_textSizeInitialized) {
      textSize = (TextPainter(
        text: TextSpan(
          text: Document.fromDelta(
            TextContent.toDelta(widget.textContents),
          ).toPlainText(),
          style: AppTextStyles.paragraph,
        ),
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: (MediaQuery.sizeOf(context).width - 32) * 0.9 - 34))
          .size;
      _textSizeInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation animation = CurvedAnimation(
      parent: ChatPagePorvider.of(context).sentMessageAnimationController,
      curve: Curves.easeOutCubic,
    );

    final double minWidth = lerpDouble(
      MediaQuery.sizeOf(context).width - 60,
      textSize.width + 34,
      animation.value,
    )!;

    final double maxWidth = (MediaQuery.sizeOf(context).width - 32) * 0.9;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(context).width - 32) * 0.9,
            minWidth: min(minWidth, maxWidth),
            maxHeight: textSize.height + 34,
          ),
          child: OverflowBox(
            alignment: Alignment.bottomRight,
            maxWidth: (MediaQuery.sizeOf(context).width - 32) * 0.9,
            maxHeight: textSize.height + 34,
            child: TextMessageView(
              textMessage: TextMessage(
                isPending: true,
                id: 'none',
                tempId: 'none',
                date: DateTime.now(),
                originalTextContents: widget.textContents,
                improvedTextContents: null,
              ),
              contextMenuShown: false,
              enableSentMessageAinmation: true,
            ),
          ),
        );
      },
    );
  }
}
