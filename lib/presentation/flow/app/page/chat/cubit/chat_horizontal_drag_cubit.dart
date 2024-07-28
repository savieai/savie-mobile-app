import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHorizontalDragCubit extends Cubit<double> {
  ChatHorizontalDragCubit() : super(0);

  void updateOffset(double offset) => emit(offset);
}
