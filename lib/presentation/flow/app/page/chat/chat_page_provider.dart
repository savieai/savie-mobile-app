import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../../domain/domain.dart';
import '../../../../presentation.dart';

class ChatPagePorvider extends InheritedWidget {
  ChatPagePorvider({
    super.key,
    required this.scrollController,
    required this.sentMessageAnimationController,
    required this.sentMessageAnimation,
    required super.child,
  }) {
    sentMessageAnimationController.addStatusListener((AnimationStatus status) {
      sentMessageAnimationStatusNotifier.value = status;
    });
  }

  final ScrollController scrollController;
  final AnimationController sentMessageAnimationController;
  final Animation<double> sentMessageAnimation;

  final ValueNotifier<AnimationStatus> sentMessageAnimationStatusNotifier =
      ValueNotifier<AnimationStatus>(AnimationStatus.dismissed);

  static Duration _sentMessageAnimationDuration =
      const Duration(milliseconds: 200);
  static Duration get sentMessageAnimationDuration =>
      _sentMessageAnimationDuration;

  static ChatPagePorvider of(BuildContext context) => maybeOf(context)!;

  static ChatPagePorvider? maybeOf(BuildContext context) {
    final ChatPagePorvider? result =
        context.dependOnInheritedWidgetOfExactType<ChatPagePorvider>();
    return result;
  }

  bool get canRunSentMessageAnimation =>
      !Platform.isMacOS &&
      scrollController.position.minScrollExtent ==
          scrollController.position.pixels;

  void runSentMessageAnimation({
    required List<TextContent> textContents,
    required BuildContext context,
  }) {
    final double height = (TextPainter(
      text: TextSpan(
        text: Document.fromDelta(
          TextContent.toDelta(textContents),
        ).toPlainText(),
        style: AppTextStyles.paragraph,
      ),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: (MediaQuery.sizeOf(context).width - 32) * 0.9 - 34))
        .height;

    final double heightRatio =
        (height / MediaQuery.sizeOf(context).height).clamp(0, 1);

    _sentMessageAnimationDuration =
        const Duration(milliseconds: 200) * (1 + heightRatio * 0.8);

    sentMessageAnimationController.duration = _sentMessageAnimationDuration;

    sentMessageAnimationController.forward().then(
          (_) => sentMessageAnimationController.reset(),
        );
  }

  @override
  bool updateShouldNotify(ChatPagePorvider oldWidget) {
    return sentMessageAnimation != oldWidget.sentMessageAnimation ||
        sentMessageAnimationController !=
            oldWidget.sentMessageAnimationController ||
        scrollController != oldWidget.scrollController;
  }
}
