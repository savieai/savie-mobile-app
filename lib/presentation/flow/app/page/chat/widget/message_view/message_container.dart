part of 'message_view.dart';

class _MessageContainer extends StatelessWidget {
  const _MessageContainer({
    required this.child,
    this.decorationOpacity = 1,
    this.animateSize = true,
    this.padding,
  });

  final Widget child;
  final double decorationOpacity;
  final bool animateSize;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: AppSpaces.space300,
            horizontal: AppSpaces.space400,
          ),
      decoration: BoxDecoration(
        color:
            AppColors.backgroundChatBubble.withValues(alpha: decorationOpacity),
        border: Border.all(
          color: AppColors.strokeSecondaryAlpha
              .withValues(alpha: decorationOpacity * 0.06),
        ),
        borderRadius: BorderRadius.circular(AppCorners.message),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 9,
            offset: const Offset(0, 2),
            color: AppColors.strokeSecondaryAlpha
                .withValues(alpha: decorationOpacity * 0.06),
          ),
        ],
      ),
      child: animateSize
          ? AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.linearToEaseOut,
              child: child,
            )
          : child,
    );
  }
}
