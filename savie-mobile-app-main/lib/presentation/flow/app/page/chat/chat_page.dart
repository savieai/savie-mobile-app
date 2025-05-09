import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/quill_delta.dart';

import '../../../../../application/application.dart';
import '../../../../../domain/domain.dart';
import '../../../../presentation.dart';
import '../../../../router/app_router.gr.dart';
import '../../drag_and_drop_wrapper.dart';
import 'chat_page_provider.dart';
import 'cubit/cubit.dart';
import 'widget/chat_horizontal_drag_listener.dart';
import 'widget/widget.dart';

ValueNotifier<KeyEvent?> keyEnventNotifier = ValueNotifier<KeyEvent?>(null);

@RoutePage()
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sentMessageAnimationController;
  late final Animation<double> _sentMessageAnimation;
  final FocusNode _focusNode = FocusNode()..requestFocus();
  final ChatPageCubit _chatPageCubit = ChatPageCubit();
  final ChatDropdownCubit _chatDropdownCubit = ChatDropdownCubit();
  final LayerLink _layerLink = LayerLink();
  final QuillControllerCubit _quillControllerCubit = QuillControllerCubit();

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
    _quillControllerCubit.addListener(() {
      _handleSingleCheckboxBackspace();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).addListener(() {
        if (FocusScope.of(context).hasPrimaryFocus) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool _metaPressed = false;
  bool _fPressed = false;
  bool _vPressed = false;
  bool _backSpacePressed = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<void>>[
        BlocProvider<ChatPageCubit>(create: (_) => _chatPageCubit),
        BlocProvider<ChatDropdownCubit>(create: (_) => _chatDropdownCubit),
        BlocProvider<QuillControllerCubit>(
          create: (_) => _quillControllerCubit,
        ),
      ],
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _onKeyEvent,
        child: BlocListener<ChatCubit, ChatState>(
          listener: (BuildContext context, ChatState state) {
            setState(() {
              _scrollController = ScrollController();
            });
          },
          listenWhen: (ChatState previous, ChatState current) =>
              previous.runtimeType != current.runtimeType,
          child: ChatPagePorvider(
            scrollController: _scrollController,
            sentMessageAnimation: _sentMessageAnimation,
            sentMessageAnimationController: _sentMessageAnimationController,
            child: Scaffold(
              appBar: const _ChatAppBar(),
              backgroundColor: AppColors.backgroundChatInput,
              body: DragAndDropWrapper(
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Expanded(
                          child: HeroVisibleArea(
                            child: MessagesHorizontalDragListener(
                              child: MessageListView(
                                scrollController: _scrollController,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            const EditingMessageView(),
                            CompositedTransformTarget(
                              link: _layerLink,
                              child: const MessageInputView(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    CompositedTransformFollower(
                      link: _layerLink,
                      targetAnchor: Alignment.topCenter,
                      followerAnchor: Alignment.bottomCenter,
                      child: Padding(
                        padding: Platform.isMacOS
                            ? const EdgeInsets.symmetric(horizontal: 24)
                            : EdgeInsets.zero,
                        child: const ChatDropdownView(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyEvent(KeyEvent value) {
    keyEnventNotifier.value = value;

    if (value.logicalKey.keyLabel.contains('Meta')) {
      _metaPressed = value is KeyDownEvent;
    }

    if (value.logicalKey.keyLabel == 'F') {
      _fPressed = value is KeyDownEvent;
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        _fPressed = false;
      });
    }

    if (value.logicalKey.keyLabel == 'V') {
      _vPressed = value is KeyDownEvent;
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        _vPressed = false;
      });
    }

    if (value.logicalKey.keyLabel == 'Escape' && value is KeyDownEvent) {
      _chatPageCubit.state.whenOrNull(editingMessage: (_) {
        _chatPageCubit.setIdle();
      });
    }

    if (_metaPressed && _fPressed) {
      if (getIt.get<AppRouter>().topRoute.name == ChatRoute.name) {
        context.router.push(const SearchRoute());
      }
    }

    if (_metaPressed && _vPressed) {
      context.read<ChatCubit>().pasteFiles();
    }

    if (value.logicalKey.keyLabel == 'Arrow Up' &&
        value is KeyDownEvent &&
        _quillControllerCubit.isEmpty) {
      final TextMessage? lastMessage =
          context.read<ChatCubit>().lastTextMessage;
      if (lastMessage != null) {
        _chatPageCubit.setEditingMessage(lastMessage);
      }
    }

    if (value.logicalKey.keyLabel == 'Backspace') {
      _backSpacePressed = value is KeyDownEvent;
      _handleSingleCheckboxBackspace();
    }
  }

  void _handleSingleCheckboxBackspace() {
    if (_backSpacePressed && _quillControllerCubit.isSingleCheckboxDisplayed) {
      _quillControllerCubit.updateDelta(Delta()..insert('\n'));
    }
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
      middle: Platform.isMacOS
          ? Assets.icons.savieLogoColor.svg()
          : const Text('Savie'),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(CustomAppBar.preferredHeight);
}
