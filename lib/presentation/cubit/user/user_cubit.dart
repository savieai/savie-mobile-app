import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../application/application.dart';
import '../../../domain/domain.dart';

@Injectable()
class UserCubit extends Cubit<SavieUser?> {
  UserCubit(
    this._authRepository,
    this._userRepository,
    this._joinWhitelistUseCase,
  ) : super(_authRepository.getAuthStatus()
            ? _userRepository.getUser()
            : null) {
    if (_userRepository.getUser() == null && _authRepository.getAuthStatus()) {
      _authRepository.logout();
    }

    if (_authRepository.getAuthStatus()) {
      _userRepository.fetchUser();
    }

    _authStatusSubscription = _authRepository.watchAuthStatus().listen(
      (bool isAuthorized) {
        if (isAuthorized) {
          _userRepository.fetchUser().then(emit);
        } else {
          emit(null);
        }
      },
    );

    _userSubscription = _userRepository.watchUser().listen((SavieUser? user) {
      if (user == null) {
        emit(null);
      } else if (_authRepository.getAuthStatus()) {
        emit(user);
      }
    });
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final JoinWhitelistUseCase _joinWhitelistUseCase;

  late final StreamSubscription<bool> _authStatusSubscription;
  late final StreamSubscription<SavieUser?> _userSubscription;

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    _userSubscription.cancel();
    return super.close();
  }

  Future<void> deleteAccount() async {
    if (await _userRepository.deleteUser()) {
      await _authRepository.logout();
    }
  }

  Future<void> joinWhiteList() => _joinWhitelistUseCase.execute();
}
