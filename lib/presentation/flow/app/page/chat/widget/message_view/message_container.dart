part of 'message_view.dart';

class _MessageContainer extends StatelessWidget {
  const _MessageContainer({
    required this.child,
    this.decorationOpacity = 1,
  });

  final Widget child;
  final double decorationOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundChatBubble.withOpacity(decorationOpacity),
        border: Border.all(
          color: AppColors.strokeSecondaryAlpha
              .withOpacity(decorationOpacity * 0.06),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 9,
            offset: const Offset(0, 2),
            color: AppColors.strokeSecondaryAlpha
                .withOpacity(decorationOpacity * 0.06),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.linearToEaseOut,
        child: child,
      ),
    );
  }
}
