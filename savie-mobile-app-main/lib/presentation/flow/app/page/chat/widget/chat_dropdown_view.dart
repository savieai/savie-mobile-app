import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../presentation.dart';
import '../cubit/cubit.dart';

class ChatDropdownView extends StatefulWidget {
  const ChatDropdownView({super.key});

  @override
  State<ChatDropdownView> createState() => _ChatDropdownViewState();
}

class _ChatDropdownViewState extends State<ChatDropdownView> {
  bool _isSrhink = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linearToEaseOut,
          decoration: _boxDecoration,
          clipBehavior: Clip.hardEdge,
          child: BlocListener<ChatDropdownCubit, bool>(
            listener: (BuildContext context, bool state) {
              setState(() {
                _isSrhink = !state;
              });
            },
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isSrhink
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: const SizedBox(width: double.infinity),
              sizeCurve: Curves.easeOutCubic,
              secondChild: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Platform.isMacOS ? 15 : 23),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          color: AppColors.backgroundPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder<ChatDropdownItem?>(
                    stream: context
                        .read<ChatDropdownCubit>()
                        .hoveredDropdownItemStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<ChatDropdownItem?> snapshot) {
                      final ChatDropdownItem? hoveredItem = snapshot.data;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ...ChatDropdownItem.values.reversed.map(
                            (ChatDropdownItem item) {
                              return _DropdownItem(
                                isHovered: hoveredItem == item,
                                item: item,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 24,
          bottom: -24,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
            width: 1,
            height: 24,
            color: _strokeColor,
          ),
        ),
        Positioned(
          right: 0,
          top: 24,
          bottom: -24,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
            width: 1,
            height: 24,
            color: _strokeColor,
          ),
        ),
      ],
    );
  }

  Color get _strokeColor => _isSrhink
      ? Colors.white.withValues(alpha: 0)
      : Color.alphaBlend(
          AppColors.strokePrimaryAlpha.withValues(alpha: 0.06),
          Colors.white,
        );

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: _strokeColor),
          left: BorderSide(color: _strokeColor),
          right: BorderSide(color: _strokeColor),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Platform.isMacOS ? 16 : 24),
        ),
      );
}

class _DropdownItem extends StatefulWidget {
  const _DropdownItem({
    required this.isHovered,
    required this.item,
  });

  final bool isHovered;
  final ChatDropdownItem item;

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => context.read<ChatDropdownCubit>().hoverDropdownItem(
            widget.item,
          ),
      onExit: (_) => context.read<ChatDropdownCubit>().unhoverDropdownItem(
            widget.item,
          ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context
            .read<ChatDropdownCubit>()
            .selectDropdownItem(ChatDropdownItem.todos),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.isHovered ? AppColors.strokeSecondaryAlpha : null,
            borderRadius: BorderRadius.circular(11),
          ),
          padding: EdgeInsets.all(Platform.isMacOS ? 8 : 12),
          child: GestureDetector(
            child: Row(
              children: <Widget>[
                Container(
                  height: 24,
                  width: 24,
                  alignment: Alignment.center,
                  child: Assets.icons.toDoSelected.svg(
                    colorFilter: const ColorFilter.mode(
                      AppColors.iconSecodary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    switch (widget.item) {
                      ChatDropdownItem.todos => 'To-do list',
                    },
                    style: AppTextStyles.paragraph,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
