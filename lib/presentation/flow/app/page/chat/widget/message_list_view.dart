import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../chat_page_provider.dart';
import 'widget.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late final ListObserverController _observerController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;
    _observerController = ListObserverController(controller: _scrollController);

    _scrollController.addListener(_scrollControllerListener);
  }

  double _previousOffset = 0;

  void _scrollControllerListener() {
    final ChatCubit chatCubit = context.read<ChatCubit>();
    if (!chatCubit.state.fetchingNext) {
      final double threshold = _scrollController.position.maxScrollExtent - 100;
      if (_scrollController.offset >= threshold &&
          _previousOffset < threshold) {
        chatCubit.fetchNext();
      }
    }

    if (!chatCubit.state.fetchingPrevious) {
      const double threshold = 100;
      if (_scrollController.offset <= threshold &&
          _previousOffset > threshold) {
        chatCubit.fetchPrevious();
      }
    }

    _previousOffset = _scrollController.offset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ChatItem> chatItems = context.select<ChatCubit, List<ChatItem>>(
      (ChatCubit cubit) => cubit.state.chatItems,
    );

    final int length = chatItems.length;

    return Container(
      color: AppColors.backgroundPrimary,
      child: ListViewObserver(
        controller: _observerController,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: _scrollController,
          reverse: true,
          slivers: <Widget>[
            ...<Widget>[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: WelcomeMessageListView(),
              ),
              if (length != 0) _ChatMessageList(chatItems: chatItems),
              SliverToBoxAdapter(
                child: SizedBox(height: length == 0 ? 32 : 20),
              ),
            ].reversed,
          ],
        ),
      ),
    );
  }
}

class _ChatMessageList extends StatelessWidget {
  const _ChatMessageList({
    required this.chatItems,
  });

  final List<ChatItem> chatItems;

  @override
  Widget build(BuildContext context) {
    // Reverse the list to display messages from newest to oldest
    final List<ChatItem> reversedChatItems = chatItems.reversed.toList();

    return SliverImplicitlyAnimatedList<ChatItem>(
      items: reversedChatItems,
      areItemsTheSame: (ChatItem a, ChatItem b) => a.currentId == b.currentId,
      insertDuration: ChatPagePorvider.sentMessageAnimationDuration,
      removeDuration: const Duration(milliseconds: 300),
      itemBuilder: (
        BuildContext context,
        Animation<double> animation,
        ChatItem chatItem,
        int index,
      ) {
        return _AnimatedChatItem(
          animation: animation,
          chatItem: chatItem,
          isRemoved: false,
        );
      },
      removeItemBuilder: (
        BuildContext context,
        Animation<double> animation,
        ChatItem chatItem,
      ) {
        return _AnimatedChatItem(
          animation: animation,
          chatItem: chatItem,
          isRemoved: true,
        );
      },
    );
  }
}

class _AnimatedChatItem extends StatelessWidget {
  const _AnimatedChatItem({
    required this.animation,
    required this.chatItem,
    required this.isRemoved,
  });

  final Animation<double> animation;
  final ChatItem chatItem;
  final bool isRemoved;

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: isRemoved ? Curves.easeOut.flipped : Curves.easeOut,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SizeTransition(
        sizeFactor: curvedAnimation,
        axisAlignment: -1,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4)
              .add(const EdgeInsets.symmetric(horizontal: 16)),
          child: chatItem.when(
            message: (Message message) => MessageView(
              key: ValueKey<String>('MessageView_${message.currentId}'),
              message: message,
            ),
            date: (DateTime date) => ChatDateView(date: date),
          ),
        ),
      ),
    );
  }
}
