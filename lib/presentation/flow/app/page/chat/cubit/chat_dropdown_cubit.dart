import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ChatDropdownCubit extends Cubit<bool> {
  ChatDropdownCubit() : super(false);

  final BehaviorSubject<ChatDropdownItem> _chatDropdownSubject =
      BehaviorSubject<ChatDropdownItem>();

  void setVisible() => emit(true);

  void setInvisible() => emit(false);

  void selectDropdownItem(ChatDropdownItem item) =>
      _chatDropdownSubject.add(item);

  Stream<ChatDropdownItem> get selectedDropdownItemStream =>
      _chatDropdownSubject.stream;
}

enum ChatDropdownItem {
  todos,
}
