part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.loggedOut() = LoggedOut;
  const factory AuthState.loggingOut() = LoggiungOut;
  const factory AuthState.loggedIn() = LoggedIn;
  const factory AuthState.loggingIn() = LoggingIn;

  const AuthState._();
}
