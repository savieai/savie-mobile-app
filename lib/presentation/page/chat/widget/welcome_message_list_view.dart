import 'package:flutter/material.dart';

import 'widget.dart';

class WelcomeMessageListView extends StatelessWidget {
  const WelcomeMessageListView({super.key});

  @override
  Widget build(BuildContext context) {
    final int length = _welcomeMessages.length;

    return SliverList.separated(
      itemBuilder: (BuildContext context, int index) {
        return WelcomeMessageView(text: _welcomeMessages[length - index - 1]);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: _welcomeMessages.length,
    );
  }

  static const List<String> _welcomeMessages = <String>[
    'Welcome to Savie',
    'A space to unload your mind 💭',
    'Write ✍🏻, attach 🧷, and record 🎙️ – all in one place',
    'Just let it flow and don’t worry about the form',
    'Savie handles the rest',
  ];
}
