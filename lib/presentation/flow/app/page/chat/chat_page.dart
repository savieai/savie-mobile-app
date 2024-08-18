import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../application/application.dart';
import '../../../../presentation.dart';
import '../../../../router/app_router.gr.dart';
import 'widget/chat_horizontal_drag_listener.dart';
import 'widget/widget.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    getIt.get<TrackUseActivityUseCase>().execute(AppEvents.chat.screenOpened);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double topInset = _getTopInset();
    if (context.read<ChatInsetsCubit>().state.top != topInset) {
      context.read<ChatInsetsCubit>().updateTopInset(topInset);
    }
  }

  double _getTopInset() =>
      MediaQuery.paddingOf(context).top + CustomAppBar.preferredHeight;

  @override
  Widget build(BuildContext context) {
    Clipboard.setData(ClipboardData(
        text: Supabase.instance.client.auth.currentSession?.accessToken ?? ''));
    return Scaffold(
      appBar: const _ChatAppBar(),
      backgroundColor: AppColors.backgroundChatInput,
      body: Column(
        children: <Widget>[
          Expanded(
            child: LayoutListener(
              onConstraintsChanged: (BoxConstraints constraints) {
                final double bottomInset = MediaQuery.sizeOf(context).height -
                    _getTopInset() -
                    constraints.maxHeight;

                context.read<ChatInsetsCubit>().updateBottomInset(bottomInset);
              },
              child: const MessagesHorizontalDragListener(
                child: MessageListView(),
              ),
            ),
          ),
          const MessageInputView(),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar();

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      leading: CustomIconButton(
        svgGenImage: Assets.icons.user24,
        color: AppColors.iconSecodary,
        onTap: () {
          context.router.push(const ProfileRoute());
          getIt
              .get<TrackUseActivityUseCase>()
              .execute(AppEvents.chat.profileButtonClicked);
        },
      ),
      trailing: CustomIconButton(
        svgGenImage: Assets.icons.search24,
        color: AppColors.iconSecodary,
        onTap: () {
          context.router.push(const SearchRoute());
          getIt
              .get<TrackUseActivityUseCase>()
              .execute(AppEvents.chat.searchButtonPressed);
        },
      ),
      middle: const Text('Today'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(CustomAppBar.preferredHeight);
}
