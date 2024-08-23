import 'package:flutter/material.dart';

import '../../../../../../../domain/model/message.dart';
import 'message_view.dart';

class SentAnimationText extends StatelessWidget {
  const SentAnimationText({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: (MediaQuery.sizeOf(context).width - 32) * 0.9,
      ),
      child: TextMessageView(
        enableSentMessageAinmation: true,
        textMessage: TextMessage(
          isPending: true,
          id: 'none',
          tempId: 'none',
          date: DateTime.now(),
          text: text,
        ),
        contextMenuShown: false,
      ),
    );
  }
}
