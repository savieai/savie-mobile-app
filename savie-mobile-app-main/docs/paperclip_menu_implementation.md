# Paperclip Menu Implementation

## Overview
This document describes the implementation of the context menu for the paperclip button in the chat input field. The paperclip button now opens a custom menu with options for attaching files, photos, and creating to-do lists.

## Changes Made

### 1. Convert FilePickerButton to StatefulWidget
The `FilePickerButton` was converted from a `StatelessWidget` to a `StatefulWidget` to manage the menu state and animations.

```dart
// Before
class FilePickerButton extends StatelessWidget {
  ...
}

// After
class FilePickerButton extends StatefulWidget {
  const FilePickerButton({super.key});

  @override
  State<FilePickerButton> createState() => _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> with SingleTickerProviderStateMixin {
  ...
}
```

### 2. Implement Menu Toggle Logic
Added logic to show and hide the menu when the paperclip icon is clicked.

```dart
void _toggleMenu(BuildContext context) {
  if (_overlayEntry != null) {
    _hideMenu();
  } else {
    _showMenu(context);
  }
}
```

### 3. Create Menu Overlay
Implemented an overlay for displaying the menu above the paperclip button.

```dart
void _showMenu(BuildContext context) {
  // Trigger haptic feedback for better UX
  HapticFeedback.lightImpact();

  // Get the position of the button
  final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject()! as RenderBox;
  final Offset position = renderBox.localToGlobal(Offset.zero);
  final Size size = renderBox.size;
  
  // ... positioning logic ...
  
  _overlayEntry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      // ... menu construction ...
    },
  );

  Overlay.of(context).insert(_overlayEntry!);
  _animationController.forward();
}
```

### 4. Create Menu Components
Created two new private widget components for the menu:

#### _PaperclipMenu
A container for the menu items with styling that matches the app's design.

```dart
class _PaperclipMenu extends StatelessWidget {
  const _PaperclipMenu({
    required this.width,
    required this.onAttachFile,
    required this.onAttachPhoto,
    required this.onCreateTodo,
  });

  // ... properties and build method ...
}
```

#### _PaperclipMenuItem
Individual menu items with proper styling and interaction effects.

```dart
class _PaperclipMenuItem extends StatefulWidget {
  const _PaperclipMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  // ... properties and state class ...
}
```

### 5. Implement Menu Actions
Connected the menu items to their respective actions:

- **Attach File**: Opens the file picker
- **Attach Photo**: Opens the camera roll or file picker (depending on platform)
- **To-do List**: Creates a to-do list in the editor using `QuillControllerCubit.enableTodos()`

```dart
onCreateTodo: () {
  _hideMenu();
  // Create a to-do list using the QuillControllerCubit
  final QuillControllerCubit quillControllerCubit = context.read<QuillControllerCubit>();
  quillControllerCubit.enableTodos();
  
  // Request focus using the QuillControllerCubit
  quillControllerCubit.requestFocus();
},
```

### 6. Improved Focus Management
Enhanced the focus management to reliably focus the text input when selecting the To-do List option:

#### 6.1 Extended QuillControllerCubit State
Created a proper state class for QuillControllerCubit that includes a focus request flag:

```dart
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
```

#### 6.2 Added Focus Request Method to QuillControllerCubit
Added a method to signal when focus should be requested:

```dart
void requestFocus() {
  // Emit a state with focusRequested set to true
  emit(state.copyWith(focusRequested: true));
  
  // Reset the focus request flag after a short delay
  Future<void>.delayed(const Duration(milliseconds: 300), () {
    emit(state.copyWith(focusRequested: false));
  });
}
```

#### 6.3 Enhanced MessageQuillEditor to Respond to Focus Requests
Updated MessageQuillEditor to listen for focus requests:

```dart
child: BlocConsumer<QuillControllerCubit, QuillControllerState>(
  listener: (context, state) {
    // Listen for focus requests and respond
    if (state.focusRequested) {
      // Request focus and force keyboard to appear
      FocusScope.of(context).requestFocus(widget.focusNode);
      
      // Force the keyboard to show
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      
      // Ensure we have a valid cursor position at the end of the document
      final controller = state.controller;
      final document = controller.document;
      final endPosition = document.length > 0 ? document.length - 1 : 0;
      
      // Set cursor position to end of document
      controller.updateSelection(
        TextSelection.collapsed(offset: endPosition),
        ChangeSource.local,
      );
    }
  },
  builder: (BuildContext context, QuillControllerState state) {
    // ... QuillEditor construction ...
  },
),
```

### 7. Add Animations
Implemented animations for showing and hiding the menu with a fade and scale effect.

```dart
FadeTransition(
  opacity: _animation,
  child: ScaleTransition(
    scale: _animation,
    alignment: position.dx >= screenWidth / 2
        ? Alignment.bottomRight
        : Alignment.bottomLeft,
    child: _PaperclipMenu(/* ... */),
  ),
),
```

## Key Features

1. **Consistent UI**: The menu matches the app's existing context menu style.
2. **Smart Positioning**: The menu positions itself above the paperclip button.
3. **Animation**: Smooth animation effects for better user experience.
4. **Haptic Feedback**: Provides haptic feedback when the menu opens.
5. **Reusable Components**: Components are designed to be reusable for other similar menus.
6. **Reliable Focus Management**: Uses a Bloc-based approach to ensure the text input receives focus.
7. **Cursor Positioning**: Automatically positions cursor at end of document.

## Benefits of the Focus Management Approach

1. **Decoupled Components**: FilePickerButton doesn't need direct access to the text input's FocusNode.
2. **State-Driven**: Uses Flutter's state management (BLoC) for handling focus requests.
3. **Reliable Timing**: Includes proper delays and safeguards to ensure focus events are processed.
4. **Error Prevention**: Includes safety checks to prevent crashes with empty documents.
5. **Cross-Platform**: Works consistently across different device types and platforms.

## Future Improvements

- Enhanced accessibility
- Support for more menu options
- Keyboard shortcuts for menu items
- Customizable menu positioning
- Improved focus transitions 