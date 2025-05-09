import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../application/application.dart';
import '../../../../../presentation.dart';
import '../../chat/widget/chat_horizontal_drag_listener.dart';
import '../../chat/widget/widget.dart';

class SearchChat extends StatefulWidget {
  const SearchChat({
    super.key,
    required this.searchController,
  });

  final TextEditingController searchController;

  @override
  State<SearchChat> createState() => _SearchChatState();
}

class _SearchChatState extends State<SearchChat> {
  ScrollController _scrollController = ScrollController();
  late final ChatCubit _chatCubit = getIt.get<ChatCubit>(
    param1: widget.searchController.text,
    param2: false,
  );

  late String _lastQuery;
  DateTime _lastChangedQuery = DateTime.now();
  bool _shouldSearch = false;

  @override
  void initState() {
    super.initState();
    _lastQuery = widget.searchController.text;
    Timer.periodic(const Duration(milliseconds: 100), (_) {
      final DateTime now = DateTime.now();

      if (now.difference(_lastChangedQuery).inMilliseconds >= 1000 &&
          _shouldSearch) {
        _chatCubit.findMessages(_lastQuery);
        _shouldSearch = false;
      }
    });

    widget.searchController.addListener(() {
      if (_lastQuery != widget.searchController.text) {
        _lastQuery = widget.searchController.text;
        _lastChangedQuery = DateTime.now();
        _shouldSearch = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) => _chatCubit,
      child: BlocListener<ChatCubit, ChatState>(
        listener: (BuildContext context, ChatState state) {
          setState(() {
            _scrollController = ScrollController();
          });
        },
        listenWhen: (ChatState previous, ChatState current) =>
            previous is ChatLoading,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: HeroVisibleArea(
            child: MessagesHorizontalDragListener(
              child: MessageListView(
                includeWelcomeMessages: false,
                scrollController: _scrollController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
