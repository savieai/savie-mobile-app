import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Singleton()
class AuthStatusCubit extends Cubit<bool> {
  AuthStatusCubit(
    this._authRepository,
  ) : super(_authRepository.getAuthStatus()) {
    _authStatusSubscription = _authRepository.watchAuthStatus().listen(emit);
  }

  late final StreamSubscription<bool> _authStatusSubscription;

  final AuthRepository _authRepository;

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    return super.close();
  }
}
