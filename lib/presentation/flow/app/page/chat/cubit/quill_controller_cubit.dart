import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

import '../../../../../../domain/domain.dart';

class QuillControllerCubit extends Cubit<QuillController> {
  QuillControllerCubit()
      : super(
          QuillController.basic(
            config: QuillControllerConfig(
              clipboardConfig: QuillClipboardConfig(
                enableExternalRichPaste: false,
                onImagePaste: (_) async {
                  return null;
                },
              ),
            ),
          ),
        );

  QuillController get _quillController => state;

  String get trimmedText =>
      _quillController.plainTextEditingValue.text.trimRight();
  bool get isEmpty => trimmedText.isEmpty;
  Delta get delta => _quillController.document.toDelta();
  List<TextContent> get textContents => TextContent.fromDelta(delta);

  bool get displayPlaceholder =>
      _quillController.document.length == 1 &&
      _quillController.plainTextEditingValue.text.trimRight().isEmpty &&
      _quillController.document.toDelta().first.isPlain;

  bool get isSingleCheckboxDisplayed =>
      _quillController.document.toDelta().length == 1 &&
      _quillController.document.toDelta().first.attributes?['list'] != null;

  bool get shouldShowDropdown {
    final TextEditingValue value = _quillController.plainTextEditingValue;
    final String lineFeed = String.fromCharCode(10);

    return value.text.endsWith('/$lineFeed') &&
        !value.text.endsWith('//$lineFeed') &&
        value.selection.baseOffset == value.text.length - 1;
  }

  final List<VoidCallback> _listeners = <VoidCallback>[];

  void addListener(VoidCallback listener) {
    _quillController.addListener(listener);
    _listeners.add(listener);
  }

  void insertNewLine() {
    final TextSelection selection = _quillController.selection;

    if (selection.isCollapsed) {
      final int insertPosition = selection.baseOffset;

      // Insert a newline character at the cursor position
      _quillController.replaceText(
        insertPosition,
        0, // No characters are replaced; it's an insertion
        '\n',
        TextSelection.collapsed(offset: insertPosition + 1),
      );
    }
  }

  void updateDelta(Delta newDelta) {
    final QuillController oldController = _quillController;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });

    final Document newDocument = Document.fromDelta(newDelta);
    final int endOffset = newDocument.length - 1;

    final QuillController newController = QuillController(
      document: Document.fromDelta(newDelta),
      selection: TextSelection.collapsed(offset: endOffset),
    );

    emit(newController);

    _listeners.forEach(newController.addListener);
    for (final VoidCallback listner in _listeners) {
      listner();
    }
  }

  void clear() => _quillController.clear();

  void applyBackspace() {
    final TextSelection selection = _quillController.selection;

    if (selection.isCollapsed && selection.baseOffset > 0) {
      final int backspacePosition = selection.baseOffset - 1;

      // Remove the character before the cursor position
      _quillController.replaceText(
        backspacePosition,
        1, // Deletes one character
        '',
        TextSelection.collapsed(offset: backspacePosition),
      );
    }
  }

  void enableTodos() => _quillController.formatSelection(Attribute.unchecked);
}
