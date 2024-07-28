part of 'message_view.dart';

class _TextWithMediaMessageView extends StatelessWidget {
  const _TextWithMediaMessageView({
    required this.message,
    required this.contextMenuShown,
  });

  final Message message;
  final bool contextMenuShown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 216 + (message.mediaPaths.length != 1 ? 32 : 0) - 18,
          ),
          child: OverflowBox(
            maxHeight: double.infinity,
            fit: OverflowBoxFit.deferToChild,
            child: MediaMessageView(
              message: message,
              contextMenuShown: contextMenuShown,
            ),
          ),
        ),
        if (message.text?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: TextMessageView(
              text: message.text ?? '',
              contextMenuShown: contextMenuShown,
            ),
          )
        else
          const SizedBox(height: 18)
      ],
    );
  }
}
