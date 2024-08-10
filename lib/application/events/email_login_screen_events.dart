import '../../domain/domain.dart';

class EmailLoginScreenEvents {
  AppEvent get screenOpened =>
      const AppEvent('authorization.login_screen.opened');

  AppEvent continuePressed({
    required String email,
  }) =>
      AppEvent(
        'authorization.welcome_screen.continue_with_apple_button.clicked',
        params: <String, String>{'email': email},
      );
}
