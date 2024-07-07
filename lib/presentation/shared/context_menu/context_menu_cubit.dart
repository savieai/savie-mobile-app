import 'package:flutter_bloc/flutter_bloc.dart';

enum ContextMenuState {
  shown,
  notShown,
}

class ContextMenuCubit extends Cubit<ContextMenuState> {
  ContextMenuCubit() : super(ContextMenuState.notShown);

  void setShown() => emit(ContextMenuState.shown);

  void setNotShown() => emit(ContextMenuState.notShown);
}
