import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../application/application.dart';
import '../../../../presentation.dart';
import '../../../../router/app_router.gr.dart';
import 'chat_page_provider.dart';
import 'widget/chat_horizontal_drag_listener.dart';
import 'widget/widget.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _sentMessageAnimationController;
  late final Animation<double> _sentMessageAnimation;

  @override
  void initState() {
    super.initState();
    getIt.get<TrackUseActivityUseCase>().execute(AppEvents.chat.screenOpened);
    _sentMessageAnimationController = AnimationController(
      vsync: this,
      duration: ChatPagePorvider.sentMessageAnimationDuration,
    );
    _sentMessageAnimation = CurvedAnimation(
      parent: _sentMessageAnimationController,
      curve: Curves.linearToEaseOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatPagePorvider(
      scrollController: _scrollController,
      sentMessageAnimation: _sentMessageAnimation,
      sentMessageAnimationController: _sentMessageAnimationController,
      child: const Scaffold(
        appBar: _ChatAppBar(),
        backgroundColor: AppColors.backgroundChatInput,
        body: Column(
          children: <Widget>[
            Expanded(
              child: HeroVisibleArea(
                child: MessagesHorizontalDragListener(
                  child: MessageListView(),
                ),
              ),
            ),
            MessageInputView(),
          ],
        ),
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
