import 'package:flutter/widgets.dart';

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

  static const Duration sentMessageAnimationDuration =
      Duration(milliseconds: 650);

  static ChatPagePorvider of(BuildContext context) => maybeOf(context)!;

  static ChatPagePorvider? maybeOf(BuildContext context) {
    final ChatPagePorvider? result =
        context.dependOnInheritedWidgetOfExactType<ChatPagePorvider>();
    return result;
  }

  bool get canRunSentMessageAnimation => scrollController.offset == 0;

  void runSentMessageAnimation() {
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
