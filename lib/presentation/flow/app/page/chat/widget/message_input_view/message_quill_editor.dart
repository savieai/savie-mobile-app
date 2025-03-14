// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, always_specify_types

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../../../presentation.dart';
import '../../cubit/cubit.dart';

class MessageQuillEditor extends StatefulWidget {
  const MessageQuillEditor({
    super.key,
    required this.scrollController,
    required this.focusNode,
    required this.onEnterPressed,
  });

  final ScrollController scrollController;
  final FocusNode focusNode;
  final VoidCallback onEnterPressed;

  @override
  State<MessageQuillEditor> createState() => _MessageQuillEditorState();
}

class _MessageQuillEditorState extends State<MessageQuillEditor> {
  late final StreamSubscription<ChatDropdownItem> _chatDropDownSubscription;
  late final QuillControllerCubit _quillControllerCubit =
      context.read<QuillControllerCubit>();

  bool _displayPlaceholder = true;

  @override
  void initState() {
    super.initState();
    _quillControllerCubit.addListener(_listener);
    _chatDropDownSubscription = context
        .read<ChatDropdownCubit>()
        .selectedDropdownItemStream
        .listen(_chatDropDownListener);
  }

  @override
  void dispose() {
    _chatDropDownSubscription.cancel();
    super.dispose();
  }

  void _listener() {
    final bool dropdownVisible = context.read<ChatDropdownCubit>().state;
    final bool shouldShowDropdown = _quillControllerCubit.shouldShowDropdown;

    if (dropdownVisible != shouldShowDropdown) {
      if (shouldShowDropdown) {
        context.read<ChatDropdownCubit>().setVisible();
      } else {
        context.read<ChatDropdownCubit>().setInvisible();
      }
    }

    // ---

    final bool displayPlaceholder = _quillControllerCubit.displayPlaceholder;

    if (displayPlaceholder != _displayPlaceholder) {
      setState(() {
        _displayPlaceholder = displayPlaceholder;
      });
    }
  }

  void _chatDropDownListener(ChatDropdownItem item) {
    _quillControllerCubit.applyBackspace();

    switch (item) {
      case ChatDropdownItem.todos:
        _quillControllerCubit.enableTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: Platform.isMacOS ? 15 : 20,
      ),
      child: BlocBuilder<QuillControllerCubit, QuillController>(
        builder: (BuildContext context, QuillController state) {
          return QuillEditor(
            controller: state,
            focusNode: widget.focusNode,
            scrollController: widget.scrollController,
            config: QuillEditorConfig(
              maxHeight: 200,
              disableClipboard: true,
              onTapOutsideEnabled: false,
              customStyles: DefaultStyles(
                lists: DefaultListBlockStyle(
                  AppTextStyles.paragraph,
                  HorizontalSpacing.zero,
                  const VerticalSpacing(4, 0),
                  const VerticalSpacing(1, 1),
                  const BoxDecoration(),
                  const CheckboxBuilder(),
                  indentWidthBuilder: (_0, _1, _2, _3) =>
                      const HorizontalSpacing(24, 0),
                  numberPointWidthBuilder: (_0, _1) => 0,
                ),
                paragraph: DefaultTextBlockStyle(
                  AppTextStyles.paragraph.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  HorizontalSpacing.zero,
                  VerticalSpacing.zero,
                  VerticalSpacing.zero,
                  const BoxDecoration(),
                ),
                placeHolder: DefaultTextBlockStyle(
                  AppTextStyles.paragraph.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  HorizontalSpacing.zero,
                  VerticalSpacing.zero,
                  VerticalSpacing.zero,
                  const BoxDecoration(),
                ),
                strikeThrough: AppTextStyles.paragraph.copyWith(
                  color: AppColors.textTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              customShortcuts: const {
                SingleActivator(LogicalKeyboardKey.enter): SaveIntent(),
              },
              customActions: {
                SaveIntent: SaveAction(onSave: widget.onEnterPressed),
              },
              enableSelectionToolbar: false,
              placeholder: _displayPlaceholder ? 'Share anything...' : null,
            ),
          );
        },
      ),
    );
  }
}

class CheckboxBuilder implements QuillCheckboxBuilder {
  const CheckboxBuilder();

  @override
  Widget build({
    required BuildContext context,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => onChanged(!isChecked),
        child: isChecked
            ? Assets.icons.toDoSelected.svg()
            : Assets.icons.toDo.svg(),
      ),
    );
  }
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class SaveAction extends Action {
  SaveAction({required this.onSave});

  final VoidCallback onSave;

  @override
  void invoke(Intent intent) => onSave();
}
