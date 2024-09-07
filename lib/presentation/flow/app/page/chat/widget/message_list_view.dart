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
    final List<Message> messages = context.select<ChatCubit, List<Message>>(
      (ChatCubit cubit) => cubit.state.messages,
    );
    final Map<String, Message> messageMap = <String, Message>{
      for (final Message m in messages) m.currentId: m,
    };

    final int length = messages.length;

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
              if (length != 0)
                SliverImplicitlyAnimatedList<String>(
                  items: messageMap.keys.toList().reversed.toList(),
                  areItemsTheSame: (String a, String b) => a == b,
                  insertDuration: ChatPagePorvider.sentMessageAnimationDuration,
                  removeDuration: const Duration(milliseconds: 300),
                  itemBuilder: (
                    _,
                    Animation<double> animation,
                    String currentId,
                    int index,
                  ) {
                    final bool isFirstInGroup = index == length - 1;

                    final Message? message = messageMap[currentId];

                    if (message == null) {
                      return const SizedBox();
                    }

                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                      child: SizeTransition(
                        sizeFactor: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        axisAlignment: -1,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: isFirstInGroup ? 46 : 0) +
                                  const EdgeInsets.only(bottom: 8, top: 4) +
                                  const EdgeInsets.symmetric(horizontal: 16),
                          child: MessageView(
                            key: Key('MessageView${message.currentId}'),
                            message: message,
                          ),
                        ),
                      ),
                    );
                  },
                  removeItemBuilder: (
                    BuildContext context,
                    Animation<double> animation,
                    String item,
                  ) {
                    final Message message =
                        context.read<ChatCubit>().state.removedMessages[item]!;

                    // TODO: track if was first in group

                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut.flipped,
                      ),
                      child: SizeTransition(
                        sizeFactor: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut.flipped,
                        ),
                        axisAlignment: -1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4) +
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: MessageView(
                            key: Key('MessageView${message.currentId}'),
                            message: message,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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

class _MessageDateStickyHeader extends StatelessWidget {
  const _MessageDateStickyHeader({
    required this.isScrollingNotifier,
    required this.date,
    required this.topPoint,
  });

  final ValueNotifier<bool> isScrollingNotifier;
  final DateTime date;
  final double topPoint;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isScrollingNotifier,
      builder: (BuildContext context, _, __) {
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        late final double curentPoint;

        try {
          curentPoint =
              renderBox?.localToGlobal(Offset.zero).dy ?? double.infinity;
        } catch (_) {
          curentPoint = double.infinity;
        }

        return ChatDateView(
          date: date,
          isPinned: curentPoint <= topPoint,
          isScrollingNotifier: isScrollingNotifier,
        );
      },
    );
  }
}
