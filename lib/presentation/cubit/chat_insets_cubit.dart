import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatInsetsCubit extends Cubit<EdgeInsets> {
  ChatInsetsCubit() : super(EdgeInsets.zero);

  void updateTopInset(double value) => emit(state.copyWith(top: value));

  void updateBottomInset(double value) => emit(state.copyWith(bottom: value));
}
