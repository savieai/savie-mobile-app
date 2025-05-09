// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, always_specify_types

import 'dart:async';

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
    required this.onSend,
  });

  final ScrollController scrollController;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  State<MessageQuillEditor> createState() => _MessageQuillEditorState();
}

class _MessageQuillEditorState extends State<MessageQuillEditor> {
  late final StreamSubscription<ChatDropdownItem?> _chatDropDownSubscription;
  late final QuillControllerCubit _quillControllerCubit =
      context.read<QuillControllerCubit>();
  // Keep a reference to the keyboard focus node
  late final FocusNode _keyboardFocusNode = FocusNode();

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
    // Dispose the keyboard focus node
    _keyboardFocusNode.dispose();
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

  void _chatDropDownListener(ChatDropdownItem? item) {
    _quillControllerCubit.applyBackspace();

    switch (item) {
      case ChatDropdownItem.todos:
        _quillControllerCubit.enableTodos();
      case null:
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDropdownVisible = context.select<ChatDropdownCubit, bool>(
      (cubit) => cubit.state,
    );

    return Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        // Always ignore key events to let the editor handle them directly
        return KeyEventResult.ignored;
      },
      child: RawKeyboardListener(
        // Use the separate focus node instead of widget.focusNode
        focusNode: _keyboardFocusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.tab) {
              // Fix: indentSelection takes a boolean argument, not ChangeSource
              _quillControllerCubit.controller.indentSelection(true);
              return;
            }
          }
        },
        child: QuillEditor(
          controller: _quillControllerCubit.controller,
          focusNode: widget.focusNode,
          scrollController: widget.scrollController,
          config: QuillEditorConfig(
            maxHeight: 200,
            minHeight: 24,
            disableClipboard: false,
            onTapOutsideEnabled: false,
            padding: const EdgeInsets.symmetric(vertical: 3),
            // Only handle the minimum required for to-do items
            onKeyPressed: (event, node) {
              // Only handle backspace for empty to-do items
              if (event.logicalKey == LogicalKeyboardKey.backspace) {
                if (_quillControllerCubit.isTodoItemAtSelectionStart() && 
                    _quillControllerCubit.isTodoItemEmpty()) {
                  _quillControllerCubit.applyBackspace();
                  return KeyEventResult.handled;
                }
              }
              
              // Let Flutter Quill handle all other cases natively
              return KeyEventResult.ignored;
            },
            customStyles: DefaultStyles(
              lists: DefaultListBlockStyle(
                AppTextStyles.paragraph,
                HorizontalSpacing.zero,
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
                const CheckboxBuilder(),
                indentWidthBuilder: (_0, _1, _2, _3) =>
                    const HorizontalSpacing(24, 0),
                numberPointWidthBuilder: (_0, _1) => 0,
              ),
              paragraph: DefaultTextBlockStyle(
                AppTextStyles.paragraph.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.0,
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
            customShortcuts: {
              const SingleActivator(LogicalKeyboardKey.enter):
                  const EnterIntent(),
              if (isDropdownVisible)
                const SingleActivator(LogicalKeyboardKey.arrowUp):
                    const ArrowUpIntent(),
              if (isDropdownVisible)
                const SingleActivator(LogicalKeyboardKey.arrowDown):
                    const ArrowDownIntent(),
            },
            customActions: {
              EnterIntent: QuillAction(onInvoke: () {
                final ChatDropdownItem? hoveredItem =
                    context.read<ChatDropdownCubit>().hoveredDropdownItem;
                if (isDropdownVisible && hoveredItem != null) {
                  context
                      .read<ChatDropdownCubit>()
                      .selectHoveredDropdownItem();
                } else {
                  widget.onSend();
                  context.read<ChatDropdownCubit>().setInvisible();
                }
              }),
              ArrowUpIntent: QuillAction(onInvoke: () {
                if (isDropdownVisible) {
                  context.read<ChatDropdownCubit>().hoverUpperDropdownItem();
                }
              }),
              ArrowDownIntent: QuillAction(onInvoke: () {
                if (isDropdownVisible) {
                  context.read<ChatDropdownCubit>().hoverLowerDropdownItem();
                }
              }),
            },
            enableSelectionToolbar: true,
            placeholder: _displayPlaceholder ? 'Share anything...' : null,
          ),
        ),
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
    // Add debug logging to diagnose the issue
    // print('CheckboxBuilder: building checkbox with isChecked=$isChecked');
    
    return SizedBox(
      height: 24,
      width: 24,
      child: Center(
        child: GestureDetector(
          onTap: () => onChanged(!isChecked),
          // Make sure the checkbox hit area is large enough
          behavior: HitTestBehavior.opaque,
          child: isChecked
              ? Assets.icons.toDoSelected.svg(height: 24, width: 24)
              : Assets.icons.toDo.svg(height: 24, width: 24),
        ),
      ),
    );
  }
}

// Custom intents to handle special keys
class EnterIntent extends Intent {
  const EnterIntent();
}

class ArrowUpIntent extends Intent {
  const ArrowUpIntent();
}

class ArrowDownIntent extends Intent {
  const ArrowDownIntent();
}

class QuillAction extends Action {
  QuillAction({required this.onInvoke});

  final VoidCallback onInvoke;

  @override
  void invoke(Intent intent) => onInvoke();
}
