part of 'message_view.dart';

class _MessageContainer extends StatelessWidget {
  const _MessageContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundChatBubble,
        border: Border.all(
          color: AppColors.strokeSecondaryAlpha,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color: AppColors.strokeSecondaryAlpha,
          ),
        ],
      ),
      child: child,
    );
  }
}
