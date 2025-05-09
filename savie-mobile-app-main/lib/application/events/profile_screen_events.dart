import '../../domain/domain.dart';

class ProfileScreenEvents {
  AppEvent get screenOpened => const AppEvent(
        'main.profile_screen.opened',
      );

  AppEvent get giftClicked => const AppEvent(
        'main.profile_screen.gift_button.clicked',
      );

  AppEvent get supportClicked => const AppEvent(
        'main.profile_screen.support_button.clicked',
      );

  AppEvent get deleteProfileClicked => const AppEvent(
        'main.profile_screen.delete_button.clicked',
      );

  AppEvent get logoutClicked => const AppEvent(
        'main.profile_screen.logout_button.clicked',
      );
}
