import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../../application/application.dart';
import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../chat_page_provider.dart';
import 'widget.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    super.key,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  double _topPoint = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    try {
      _topPoint = renderBox?.localToGlobal(Offset.zero).dy ?? 0;
    } catch (_) {
      // ignore, really
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Message> messages = context.select<ChatCubit, List<Message>>(
      (ChatCubit cubit) => cubit.state.messages,
    );
    final int length = messages.length;
    final Map<DateTime, Map<String, Message>> groupedMessages =
        _groupMessages(messages);

    final ScrollController scrollController =
        ChatPagePorvider.of(context).scrollController;

    return Container(
      color: AppColors.backgroundPrimary,
      child: ListViewObserver(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: scrollController,
          reverse: true,
          slivers: <Widget>[
            ...<Widget>[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: WelcomeMessageListView(),
              ),
              if (length != 0)
                ...groupedMessages.keys.map((DateTime date) {
                  return SliverStickyHeader.builder(
                    key: ValueKey<DateTime>(date),
                    reverse: true,
                    overlapsContent: true,
                    builder: (_, __) => _MessageDateStickyHeader(
                      isScrollingNotifier:
                          scrollController.position.isScrollingNotifier,
                      topPoint: _topPoint,
                      date: date,
                    ),
                    sliver: SliverImplicitlyAnimatedList<String>(
                      items: groupedMessages[date]!
                          .values
                          .map((Message m) => m.currentId)
                          .toList()
                          .reversed
                          .toList(),
                      areItemsTheSame: (String a, String b) => a == b,
                      insertDuration:
                          ChatPagePorvider.sentMessageAnimationDuration,
                      removeDuration: const Duration(milliseconds: 300),
                      itemBuilder: (
                        _,
                        Animation<double> animation,
                        String currentId,
                        int index,
                      ) {
                        final int length = groupedMessages[date]!.length;
                        final bool isFirstInGroup = index == length - 1;

                        final Message? message =
                            groupedMessages[date]![currentId];

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
                              padding: EdgeInsets.only(
                                      top: isFirstInGroup ? 46 : 0) +
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
                        final Message message = context
                            .read<ChatCubit>()
                            .state
                            .removedMessages[item]!;

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
                              padding: const EdgeInsets.only(
                                      bottom: 8, top: 4) +
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
                  );
                }),
              SliverToBoxAdapter(
                  child: SizedBox(height: length == 0 ? 32 : 20)),
            ].reversed,
          ],
        ),
      ),
    );
  }
}

Map<DateTime, Map<String, Message>> _groupMessages(List<Message> messages) {
  final Map<DateTime, List<Message>> groupedItems = <DateTime, List<Message>>{};

  // Group messages by date
  for (final Message message in messages) {
    final DateTime group = message.date.toDate;
    if (!groupedItems.containsKey(group)) {
      groupedItems[group] = <Message>[];
    }
    groupedItems[group]!.add(message);
  }

  // Sort the keys (dates)
  final List<MapEntry<DateTime, List<Message>>> sortedEntries = groupedItems
      .entries
      .toList()
    ..sort((MapEntry<DateTime, List<Message>> e1,
            MapEntry<DateTime, List<Message>> e2) =>
        e1.key.compareTo(e2.key));

  // Convert sorted entries back to a map
  final Map<DateTime, List<Message>> sortedGroupedItems =
      Map<DateTime, List<Message>>.fromEntries(sortedEntries);

  return sortedGroupedItems.map((DateTime key, List<Message> value) => MapEntry(
        key,
        <String, Message>{
          for (final Message m in value) m.currentId: m,
        },
      ));
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
