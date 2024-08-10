import '../../domain/domain.dart';

class ReferralCheckScreenEvents {
  AppEvent get screenOpened => const AppEvent(
        'authorization.referral_check_screen.opened',
      );

  AppEvent get success => const AppEvent(
        'authorization.referral_check_screen.success_event',
      );

  AppEvent get joinWhitelistPressed => const AppEvent(
        'authorization.referral_check_screen.join_waitlist_button.clicked',
      );
}
