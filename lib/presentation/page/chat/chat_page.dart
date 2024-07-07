import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/application.dart';
import '../../presentation.dart';
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
    return MultiBlocProvider(
      providers: <BlocProvider<void>>[
        BlocProvider<ChatCubit>(
          create: (_) => getIt.get<ChatCubit>(),
        ),
        BlocProvider<RecordingCubit>(
          create: (_) => getIt.get<RecordingCubit>(),
        ),
      ],
      child: Scaffold(
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

                  context
                      .read<ChatInsetsCubit>()
                      .updateBottomInset(bottomInset);
                },
                child: const MessageListView(),
              ),
            ),
            const MessageInputView(),
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
        onTap: null,
      ),
      trailing: CustomIconButton(
        svgGenImage: Assets.icons.search24,
        color: AppColors.iconSecodary,
        onTap: null,
      ),
      middle: const Text('Today'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(CustomAppBar.preferredHeight);
}
