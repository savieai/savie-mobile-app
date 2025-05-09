import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

import '../../../../../../domain/domain.dart';

class QuillControllerState {
  final QuillController controller;
  final bool focusRequested;

  QuillControllerState({
    required this.controller,
    this.focusRequested = false,
  });

  QuillControllerState copyWith({
    QuillController? controller,
    bool? focusRequested,
  }) {
    return QuillControllerState(
      controller: controller ?? this.controller,
      focusRequested: focusRequested ?? this.focusRequested,
    );
  }
}

class QuillControllerCubit extends Cubit<QuillControllerState> {
  QuillControllerCubit()
      : super(
          QuillControllerState(
            controller: QuillController.basic(
              config: QuillControllerConfig(
                clipboardConfig: QuillClipboardConfig(
                  enableExternalRichPaste: false,
                  onImagePaste: (_) async {
                    return null;
                  },
                ),
              ),
            ),
          ),
        );

  QuillController get _quillController => state.controller;

  String get trimmedText =>
      _quillController.plainTextEditingValue.text.trimRight();
  bool get isEmpty => trimmedText.isEmpty;
  Delta get delta => _quillController.document.toDelta();
  List<TextContent> get textContents => TextContent.fromDelta(delta);

  bool get displayPlaceholder {
    // Check if document has only one operation
    if (_quillController.document.length != 1) {
      return false;
    }
    
    // Check if text is empty or only whitespace
    if (!_quillController.plainTextEditingValue.text.trimRight().isEmpty) {
      return false;
    }
    
    // Get the first operation in the delta
    final firstOp = _quillController.document.toDelta().first;
    
    // A "plain" operation has no formatting attributes
    return firstOp.attributes == null || firstOp.attributes!.isEmpty;
  }

  bool get isSingleCheckboxDisplayed =>
      _quillController.document.toDelta().length == 1 &&
      _quillController.document.toDelta().first.attributes?['list'] != null;

  bool get shouldShowDropdown {
    // Disabled slash command feature
    return false;
    
    // Original implementation:
    // final TextEditingValue value = _quillController.plainTextEditingValue;
    // final String lineFeed = String.fromCharCode(10);
    // 
    // return value.text.endsWith('/$lineFeed') &&
    //     !value.text.endsWith('//$lineFeed') &&
    //     value.selection.baseOffset == value.text.length - 1;
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

    emit(state.copyWith(controller: newController));

    _listeners.forEach(newController.addListener);
    for (final VoidCallback listner in _listeners) {
      listner();
    }
  }

  void clear() {
    final QuillController oldController = _quillController;
    
    // Create a completely new controller with empty document
    final QuillController newController = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: false,
          onImagePaste: (_) async {
            return null;
          },
        ),
      ),
    );
    
    // Update the state with the new controller
    emit(state.copyWith(controller: newController));
    
    // Transfer listeners to the new controller
    _listeners.forEach(newController.addListener);
    
    // Call all listeners to notify of changes
    for (final VoidCallback listener in _listeners) {
      listener();
    }
    
    // Dispose the old controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });
  }

  // Fix backspace handling to ensure it always works
  void applyBackspace() {
    // Get the current position
    final selection = _quillController.selection;
    final currentOffset = selection.baseOffset;
    
    if (currentOffset > 0) {
      // Delete one character before the cursor
      _quillController.replaceText(
        currentOffset - 1,
        1,
        '',
        null,
      );
      
      // Maintain focus by explicitly setting the cursor position
      _quillController.updateSelection(
        TextSelection.collapsed(offset: currentOffset - 1),
        ChangeSource.local,
      );
    }
  }

  // Helper to check if the current line is a to-do item
  bool isTodoItemAtSelectionStart() {
    final offset = _quillController.selection.baseOffset;
    final lineStart = _getLinesStartOffset(offset);
    
    if (lineStart < 0) return false;
    
    try {
      final node = _quillController.document.queryChild(lineStart).node;
      if (node == null) return false;
      
      // Check if this line has list attribute set to checked or unchecked
      final attrs = node.style.attributes;
      return attrs.containsKey(Attribute.list.key) && 
            (attrs[Attribute.list.key]?.value == Attribute.checked.value || 
             attrs[Attribute.list.key]?.value == Attribute.unchecked.value);
    } catch (e) {
      return false;
    }
  }
  
  // Helper to check if the to-do item is empty (only contains whitespace or zero-width spaces)
  bool isTodoItemEmpty() {
    final offset = _quillController.selection.baseOffset;
    final lineStart = _getLinesStartOffset(offset);
    final lineEnd = _getLinesEndOffset(offset);
    
    if (lineStart < 0 || lineEnd < 0) return false;
    
    // Get the text content of this line
    final lineText = _quillController.document.getPlainText(lineStart, lineEnd - lineStart);
    
    // Check if it's empty or contains only whitespace or zero-width spaces
    if (lineText.isEmpty) return true;
    
    // Check for only whitespace characters
    if (lineText.trim().isEmpty) return true;
    
    // Check for zero-width spaces (Unicode 8203)
    if (lineText.codeUnits.every((unit) => unit == 8203 || unit == 32)) return true;
    
    return false;
  }
  
  // Gets the start offset of the current line
  int _getLinesStartOffset(int offset) {
    final text = _quillController.plainTextEditingValue.text;
    if (text.isEmpty) return -1;
    
    // Find the previous newline or start of text
    for (int i = offset - 1; i >= 0; i--) {
      if (text[i] == '\n') {
        return i + 1;
      }
    }
    return 0;
  }
  
  // Gets the end offset of the current line
  int _getLinesEndOffset(int offset) {
    final text = _quillController.plainTextEditingValue.text;
    if (text.isEmpty) return -1;
    
    // Find the next newline or end of text
    for (int i = offset; i < text.length; i++) {
      if (text[i] == '\n') {
        return i;
      }
    }
    return text.length;
  }
  
  // Get the start offset of the to-do line
  int getTodoLineStartOffset() {
    final offset = _quillController.selection.baseOffset;
    return _getLinesStartOffset(offset);
  }

  void enableTodos() {
    // If document is empty, ensure we don't add any zero-width spaces
    if (_quillController.document.isEmpty()) {
      _quillController.replaceText(0, 0, '', null);
    }
    
    // Determine if current selection is valid
    final TextSelection currentSel = _quillController.selection;
    final bool hasValidSelection =
        currentSel.baseOffset >= 0 && currentSel.extentOffset >= 0;

    final TextSelection selection = hasValidSelection
        ? currentSel
        : const TextSelection.collapsed(offset: 0);
    
    // Apply the to-do formatting
    _quillController.formatSelection(Attribute.unchecked);
    
    // Ensure the current line doesn't have invisible characters
    final lineStart = _getLinesStartOffset(selection.baseOffset);
    final lineEnd = _getLinesEndOffset(selection.baseOffset);
    
    if (lineStart >= 0 && lineEnd >= 0) {
      final lineText = _quillController.document.getPlainText(lineStart, lineEnd - lineStart);
      
      // If the line has only whitespace or zero-width spaces, replace with empty string
      if (lineText.isNotEmpty && (lineText.trim().isEmpty || 
          lineText.codeUnits.every((unit) => unit == 8203 || unit == 32))) {
        _quillController.replaceText(
          lineStart,
          lineEnd - lineStart,
          '',
          TextSelection.collapsed(offset: lineStart),
        );
      }
    }
    
    // Ensure selection is maintained at a valid position
    if (_quillController.document.length > 0) {
      final int position = _quillController.document.length > 1 
          ? _quillController.document.length - 1 
          : 0;
          
      _quillController.updateSelection(
        TextSelection.collapsed(offset: position),
        ChangeSource.local,
      );
    }
    
    // Make sure all todo items have correct formatting, especially the last one
    ensureTodoItemsFormatting();
  }
  
  // Add a method to check and fix todo items in delta
  void ensureTodoItemsFormatting() {
    final Document doc = _quillController.document;
    
    // Instead of directly iterating through document nodes,
    // let's work with the delta representation which is safer
    final delta = doc.toDelta();
    
    // Check if the document contains any todo lists
    bool hasTodoItems = false;
    for (final op in delta.operations) {
      if (op.attributes != null && 
          op.attributes!.containsKey('list') &&
          (op.attributes!['list'] == 'checked' || op.attributes!['list'] == 'unchecked')) {
        hasTodoItems = true;
        break;
      }
    }
    
    if (!hasTodoItems) return; // No todo items, nothing to fix
    
    // If there are todo items, make sure the last line has the proper formatting
    // Check the last operation
    if (delta.operations.isNotEmpty) {
      final lastOp = delta.operations.last;
      
      // If the last operation is a newline without attributes, add list attributes
      if (lastOp.isInsert && 
          lastOp.data is String && 
          (lastOp.data as String) == '\n' &&
          (lastOp.attributes == null || !lastOp.attributes!.containsKey('list'))) {
        
        // Find the previous list item attribute
        Operation? previousListOp;
        for (int i = delta.operations.length - 2; i >= 0; i--) {
          final op = delta.operations[i];
          if (op.attributes != null && op.attributes!.containsKey('list')) {
            previousListOp = op;
            break;
          }
        }
        
        // If we found a list attribute, apply it to the last newline
        if (previousListOp != null && previousListOp.attributes != null) {
          // Create a new document with the fixed delta
          final fixedDelta = Delta();
          for (int i = 0; i < delta.operations.length - 1; i++) {
            fixedDelta.push(delta.operations[i]);
          }
          fixedDelta.insert('\n', previousListOp.attributes);
          
          // Update the controller with the fixed delta
          _quillController.compose(
            fixedDelta, 
            const TextSelection.collapsed(offset: 0),
            ChangeSource.local,
          );
        }
      }
    }
  }
  
  void requestFocus() {
    // Emit a state with focusRequested set to true
    emit(state.copyWith(focusRequested: true));
    
    // Reset the focus request flag after a short delay
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!isClosed) {
        emit(state.copyWith(focusRequested: false));
      }
    });
  }

  // Getter for the quill controller
  QuillController get controller => _quillController;
}
