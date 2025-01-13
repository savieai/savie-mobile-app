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
    return AnimatedContainer(
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
          crossFadeState:
              _isSrhink ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: const SizedBox(width: double.infinity),
          sizeCurve: Curves.easeOutCubic,
          secondChild: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: AppColors.backgroundPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context
                    .read<ChatDropdownCubit>()
                    .selectDropdownItem(ChatDropdownItem.todos),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                            'To-do list',
                            style: AppTextStyles.paragraph,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: AppColors.strokePrimaryAlpha.withValues(
              alpha: _isSrhink ? 0 : 0.06,
            ),
          ),
          left: BorderSide(
            color: AppColors.strokePrimaryAlpha.withValues(
              alpha: _isSrhink ? 0 : 0.06,
            ),
          ),
          right: BorderSide(
            color: AppColors.strokePrimaryAlpha.withValues(
              alpha: _isSrhink ? 0 : 0.06,
            ),
          ),
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      );
}
