import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../presentation.dart';
import 'widget.dart';

class MessageListView extends StatelessWidget {
  const MessageListView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      reverse: true,
      slivers: <Widget>[
        ...<Widget>[
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const WelcomeMessageListView(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (BuildContext context, ChatState state) {
              final int length = state.messages.length;

              return SliverList.separated(
                itemBuilder: (BuildContext context, int index) {
                  return MessageView(
                    message: state.messages[length - index - 1],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: length,
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ].reversed.map(
              (Widget w) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: w,
              ),
            ),
      ],
    );
  }
}
