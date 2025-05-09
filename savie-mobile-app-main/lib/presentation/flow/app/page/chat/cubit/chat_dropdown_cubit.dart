import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ChatDropdownCubit extends Cubit<bool> {
  ChatDropdownCubit() : super(false);

  final BehaviorSubject<ChatDropdownItem?> _selectedChatDropdownSubject =
      BehaviorSubject<ChatDropdownItem?>.seeded(null);

  final BehaviorSubject<ChatDropdownItem?> _hoveredChatDropdownSubject =
      BehaviorSubject<ChatDropdownItem?>.seeded(null);

  void setVisible() => emit(true);

  void setInvisible() {
    _selectedChatDropdownSubject.value = null;
    _hoveredChatDropdownSubject.value = null;
    emit(false);
  }

  void selectDropdownItem(ChatDropdownItem item) =>
      _selectedChatDropdownSubject.add(item);

  void selectHoveredDropdownItem() {
    final ChatDropdownItem? hoveredItem = _hoveredChatDropdownSubject.value;
    if (hoveredItem != null) {
      _selectedChatDropdownSubject.add(hoveredItem);
    }
  }

  void hoverUpperDropdownItem() {
    final ChatDropdownItem? hoveredItem = _hoveredChatDropdownSubject.value;
    final ChatDropdownItem upperItem = hoveredItem == null
        ? ChatDropdownItem.values.first
        : hoveredItem.index == ChatDropdownItem.values.length - 1
            ? ChatDropdownItem.values.last
            : ChatDropdownItem.values[hoveredItem.index + 1];
    _hoveredChatDropdownSubject.add(upperItem);
  }

  void hoverLowerDropdownItem() {
    final ChatDropdownItem? hoveredItem = _hoveredChatDropdownSubject.value;
    final ChatDropdownItem? lowerItem =
        hoveredItem == null || hoveredItem.index == 0
            ? null
            : ChatDropdownItem.values[hoveredItem.index - 1];
    _hoveredChatDropdownSubject.add(lowerItem);
  }

  void hoverDropdownItem(ChatDropdownItem item) =>
      _hoveredChatDropdownSubject.add(item);

  void unhoverDropdownItem(ChatDropdownItem item) {
    if (item == _hoveredChatDropdownSubject.value) {
      _hoveredChatDropdownSubject.add(null);
    }
  }

  Stream<ChatDropdownItem?> get selectedDropdownItemStream =>
      _selectedChatDropdownSubject.stream;

  Stream<ChatDropdownItem?> get hoveredDropdownItemStream =>
      _hoveredChatDropdownSubject.stream;

  ChatDropdownItem? get hoveredDropdownItem =>
      _hoveredChatDropdownSubject.value;
}

enum ChatDropdownItem {
  todos,
}
