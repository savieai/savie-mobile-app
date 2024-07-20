import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

@Singleton()
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(_initialState(_authRepository));

  final AuthRepository _authRepository;

  static AuthState _initialState(AuthRepository authRepository) {
    return _authStatusToState(authRepository.getAuthStatus());
  }

  Future<void> signInWithApple() async {
    if (state is! LoggedOut) {
      return;
    }

    emit(const AuthState.loggingIn());
    final bool result = await _authRepository.signInWithApple();
    emit(_authStatusToState(result));
  }

  Future<void> signInWithGoogle() async {
    if (state is! LoggedOut) {
      return;
    }

    emit(const AuthState.loggingIn());
    final bool result = await _authRepository.signInWithGoogle();
    emit(_authStatusToState(result));
  }

  /// Emits [LoggingIn] state
  ///
  /// Email submission logic is handled by [OTPCubit]
  Future<void> initiateEmailSignIn() async {
    if (state is! LoggedOut) {
      return;
    }

    emit(const AuthState.loggingIn());
  }

  /// Emits [LoggedOut] or [LoggedIn] state, based on [result]
  /// which is produced by [OTPCubit]
  Future<void> closeEmailSingIn({
    required bool result,
  }) async {
    emit(_authStatusToState(result));
  }

  Future<void> logOut() async {
    emit(const AuthState.loggingOut());
    await _authRepository.logout();
    emit(const AuthState.loggedOut());
  }

  static AuthState _authStatusToState(bool value) =>
      value ? const AuthState.loggedIn() : const AuthState.loggedOut();
}
