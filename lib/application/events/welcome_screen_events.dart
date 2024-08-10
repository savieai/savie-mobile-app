import '../../domain/domain.dart';

class WlcomeScreenEvents {
  AppEvent get screenOpened =>
      const AppEvent('authorization.welcome_screen.opened');

  AppEvent get appleButtonPressed => const AppEvent(
      'authorization.welcome_screen.continue_with_apple_button.clicked');

  AppEvent get googleButtonPressed => const AppEvent(
      'authorization.welcome_screen.continue_with_google_button.clicked');

  AppEvent get emailButtonPressed => const AppEvent(
      'authorization.welcome_screen.continue_with_email_button.clicked');

  AppEvent get privacyPolicyPressed => const AppEvent(
      'authorization.welcome_screen.privacy_policy_button.clicked');

  AppEvent get termsOfUsePressed => const AppEvent(
      'authorization.welcome_screen.terms_of_use_button.clicked');
}
