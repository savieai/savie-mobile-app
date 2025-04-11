import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/domain.dart';
import '../../../../../presentation.dart';
import '../cubit/cubit.dart';

class EditingMessageView extends StatefulWidget {
  const EditingMessageView({super.key});

  @override
  State<EditingMessageView> createState() => _EditingMessageViewState();
}

class _EditingMessageViewState extends State<EditingMessageView> {
  late TextMessage? _displayedMessage =
      context.read<ChatPageCubit>().state.whenOrNull(
            editingMessage: (TextMessage message) => message,
          );

  bool _isSrhink = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linearToEaseOut,
        decoration: _boxDecoration,
        child: BlocListener<ChatPageCubit, ChatPageState>(
          listener: (BuildContext context, ChatPageState state) {
            state.when(
              idle: (_) => setState(() => _isSrhink = true),
              editingMessage: (TextMessage message) {
                setState(() {
                  _displayedMessage = message;
                  _isSrhink = false;
                });
              },
            );
          },
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isSrhink
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const SizedBox(width: double.infinity),
            sizeCurve: Curves.easeOutCubic,
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Edit',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.iconAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _displayedMessage?.currentPlainText ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.callout,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomIconButton(
                    svgGenImage: Assets.icons.close24,
                    color: AppColors.iconSecodary,
                    onTap: context.read<ChatPageCubit>().setIdle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration get _boxDecoration => BoxDecoration(
        color: AppColors.backgroundPrimary,
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
