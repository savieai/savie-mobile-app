import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../../../../../../application/application.dart';
import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import 'widget.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    super.key,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final ScrollController _scrollController = ScrollController();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Message> messages = context.select<ChatCubit, List<Message>>(
      (ChatCubit cubit) => cubit.state.messages,
    );
    final int length = messages.length;
    final Map<DateTime, List<Message>> groupedMessages =
        _groupMessages(messages);

    return Container(
      color: AppColors.backgroundPrimary,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: _scrollController,
        reverse: true,
        slivers: <Widget>[
          ...<Widget>[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const WelcomeMessageListView(),
            if (length != 0)
              ...groupedMessages.keys.map((DateTime date) {
                return SliverStickyHeader.builder(
                  reverse: true,
                  overlapsContent: true,
                  builder: (_, __) => _MessageDateStickyHeader(
                    isScrollingNotifier:
                        _scrollController.position.isScrollingNotifier,
                    topPoint: _topPoint,
                    date: date,
                  ),
                  sliver: SliverList.separated(
                    itemBuilder: (_, int index) {
                      final int length = groupedMessages[date]!.length;
                      final bool isFirstInGroup = index == length - 1;
                      return Padding(
                        padding: EdgeInsets.only(top: isFirstInGroup ? 58 : 0),
                        child: MessageView(
                          message: groupedMessages[date]![length - index - 1],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: groupedMessages[date]!.length,
                  ),
                );
              }),
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

Map<DateTime, List<Message>> _groupMessages(List<Message> messages) {
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

  return sortedGroupedItems;
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
