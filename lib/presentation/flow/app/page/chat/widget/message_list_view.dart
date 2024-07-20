import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import 'widget.dart';

class MessageListView extends StatelessWidget {
  const MessageListView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Message> messages = context.select<ChatCubit, List<Message>>(
      (ChatCubit cubit) => cubit.state.messages,
    );
    final int length = messages.length;

    return Container(
      color: AppColors.backgroundPrimary,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        reverse: true,
        slivers: <Widget>[
          ...<Widget>[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const WelcomeMessageListView(),
            if (length != 0)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverList.separated(
              itemBuilder: (BuildContext context, int index) {
                return MessageView(
                  message: messages[length - index - 1],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: length,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ].reversed.map(
                (Widget w) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  sliver: w,
                ),
              ),
        ],
      ),
    );
  }
}
