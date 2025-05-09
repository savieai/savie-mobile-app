import 'dart:io';
import 'dart:math';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../chat_page_provider.dart';
import 'widget.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    super.key,
    required this.scrollController,
    this.includeWelcomeMessages = true,
  });

  final ScrollController scrollController;
  final bool includeWelcomeMessages;

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;

    _scrollController.addListener(_scrollControllerListener);
  }

  double _previousOffset = 0;

  @override
  void didUpdateWidget(covariant MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController = widget.scrollController;

      _scrollController.addListener(_scrollControllerListener);
    }
  }

  void _scrollControllerListener() {
    final ChatCubit chatCubit = context.read<ChatCubit>();
    chatCubit.state.mapOrNull(
      fetched: (ChatFetched state) {
        if (!state.fetchingNext) {
          final double threshold =
              _scrollController.position.maxScrollExtent - 500;
          if (_scrollController.offset >= threshold &&
              _previousOffset < threshold) {
            chatCubit.fetchEarlierMessages();
          }
        }

        if (!state.fetchingPrevious) {
          final double threshold =
              _scrollController.position.minScrollExtent + 500;

          if (_scrollController.offset <= threshold &&
              _previousOffset > threshold) {
            chatCubit.fetchLaterMessages();
          }
        }

        _previousOffset = _scrollController.offset;
      },
    );
  }

  GlobalKey _centerKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.removeListener(_scrollControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (BuildContext context, ChatState state) async {
        setState(() {
          _centerKey = GlobalKey();
        });
      },
      listenWhen: (ChatState previous, ChatState current) =>
          previous is ChatLoading,
      builder: (BuildContext context, ChatState state) {
        return Container(
          color: AppColors.backgroundPrimary,
          child: state.map(
            loading: (_) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            },
            fetched: (ChatFetched fetched) {
              final List<ChatItem> earlierChatItems = fetched.earlierMessages;
              final List<ChatItem> laterChatItems = fetched.laterMessages;

              final int totalLength =
                  earlierChatItems.length + laterChatItems.length;

              return CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: _scrollController,
                center: _centerKey,
                reverse: true,
                slivers: <Widget>[
                  ...<Widget>[
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    if (widget.includeWelcomeMessages)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Platform.isMacOS ? 24 : 16,
                        ),
                        sliver: const WelcomeMessageListView(),
                      ),
                    SliverPadding(
                      key: _centerKey,
                      padding: EdgeInsets.only(
                        bottom: laterChatItems.isEmpty ? 24 : 0,
                      ),
                      sliver: earlierChatItems.isNotEmpty
                          ? _ChatMessageList(
                              chatItems: earlierChatItems,
                            )
                          : const SliverToBoxAdapter(child: SizedBox()),
                    ),
                    if (laterChatItems.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 24),
                        sliver: _ChatMessageList(
                          chatItems: laterChatItems,
                          newMessageRenderedCallback: () {
                            _scrollController.animateTo(
                              _scrollController.position.minScrollExtent,
                              duration: ChatPagePorvider
                                      .sentMessageAnimationDuration *
                                  0.6,
                              curve: Curves.easeOut,
                            );
                          },
                          hadInitiallyMinScrollExtent: _scrollController
                                  .hasClients &&
                              _scrollController.position.minScrollExtent + 50 >=
                                  _scrollController.offset,
                          useSizeAnimation: false,
                        ),
                      ),
                    if (totalLength == 0)
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 12),
                      ),
                  ].reversed,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ChatMessageList extends StatelessWidget {
  const _ChatMessageList({
    required this.chatItems,
    this.newMessageRenderedCallback,
    this.useSizeAnimation = true,
    this.hadInitiallyMinScrollExtent,
  });

  final List<ChatItem> chatItems;
  final VoidCallback? newMessageRenderedCallback;
  final bool useSizeAnimation;
  final bool? hadInitiallyMinScrollExtent;

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
          newMessageRenderedCallback: newMessageRenderedCallback,
          useSizeAnimation: useSizeAnimation,
          hadInitiallyMinScrollExtent: hadInitiallyMinScrollExtent,
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

Set<String> _reportedHeights = <String>{};

class _AnimatedChatItem extends StatelessWidget {
  const _AnimatedChatItem({
    required this.animation,
    required this.chatItem,
    required this.isRemoved,
    this.newMessageRenderedCallback,
    this.useSizeAnimation = true,
    this.hadInitiallyMinScrollExtent,
  });

  final Animation<double> animation;
  final ChatItem chatItem;
  final bool isRemoved;
  final VoidCallback? newMessageRenderedCallback;
  final bool useSizeAnimation;
  final bool? hadInitiallyMinScrollExtent;

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: isRemoved ? Curves.easeOut.flipped : Curves.easeOut,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: UnclippedSizeTransition(
        sizeFactor: useSizeAnimation
            ? curvedAnimation
            : const AlwaysStoppedAnimation<double>(1),
        axisAlignment: -1,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Platform.isMacOS ? 24 : 16) +
                  (chatItem is MessageChatItem
                      ? EdgeInsets.only(
                          top: AppSpaces.space300 / 3,
                          bottom: AppSpaces.space300 / 3 * 2,
                        )
                      : EdgeInsets.zero),
          child: chatItem.when(
            message: (Message message) => Builder(
              builder: (BuildContext context) {
                if (message.isNew &&
                    !_reportedHeights.contains(message.currentId) &&
                    (hadInitiallyMinScrollExtent ?? false)) {
                  _reportedHeights.add(message.currentId);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    newMessageRenderedCallback?.call();
                  });
                }

                return MessageView(
                  key: ValueKey<String>('MessageView_${message.currentId}'),
                  message: message,
                );
              },
            ),
            date: (DateTime date) => ChatDateView(date: date),
          ),
        ),
      ),
    );
  }
}

class UnclippedSizeTransition extends AnimatedWidget {
  const UnclippedSizeTransition({
    super.key,
    this.axis = Axis.vertical,
    required Animation<double> sizeFactor,
    this.axisAlignment = 0.0,
    this.fixedCrossAxisSizeFactor,
    this.child,
  })  : assert(fixedCrossAxisSizeFactor == null ||
            fixedCrossAxisSizeFactor >= 0.0),
        super(listenable: sizeFactor);

  final Axis axis;
  Animation<double> get sizeFactor => listenable as Animation<double>;
  final double axisAlignment;
  final double? fixedCrossAxisSizeFactor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: switch (axis) {
        Axis.horizontal => AlignmentDirectional(axisAlignment, -1.0),
        Axis.vertical => AlignmentDirectional(-1.0, axisAlignment),
      },
      heightFactor: axis == Axis.vertical
          ? max(sizeFactor.value, 0.0)
          : fixedCrossAxisSizeFactor,
      widthFactor: axis == Axis.horizontal
          ? max(sizeFactor.value, 0.0)
          : fixedCrossAxisSizeFactor,
      child: child,
    );
  }
}
