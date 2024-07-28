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
    return _MessageContainer(
      child: SelectableText(
        text,
        enableInteractiveSelection: contextMenuShown,
        cursorWidth: 0,
        style: AppTextStyles.paragraph.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
