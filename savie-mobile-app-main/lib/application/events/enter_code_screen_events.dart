import '../../domain/domain.dart';

class EnterCodeScreenEvents {
  AppEvent screenOpened({
    required String email,
  }) =>
      AppEvent(
        'authorization.enter_code_screen.opened',
        params: <String, String>{'email': email},
      );

  AppEvent resendButtonPressed({
    required String email,
  }) =>
      AppEvent(
        'authorization.enter_code_screen.resend_code_button.clicked',
        params: <String, String>{'email': email},
      );

  AppEvent continuePressed({
    required String email,
  }) =>
      AppEvent(
        'authorization.enter_code_screen.continue_button.clicked',
        params: <String, String>{'email': email},
      );

  AppEvent codeIncorrect({
    required String email,
  }) =>
      AppEvent(
        'authorization.enter_code_screen.incorrect_code_event',
        params: <String, String>{'email': email},
      );
}
