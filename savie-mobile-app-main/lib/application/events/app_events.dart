import 'chat_screen_events.dart';
import 'email_login_screen_events.dart';
import 'enter_code_screen_events.dart';
import 'media_selection_screen_events.dart';
import 'photo_view_screen_events.dart';
import 'popup_screen_events.dart';
import 'profile_screen_events.dart';
import 'referral_check_screen_events.dart';
import 'welcome_screen_events.dart';

sealed class AppEvents {
  static WlcomeScreenEvents welcome = WlcomeScreenEvents();
  static EmailLoginScreenEvents emailLogin = EmailLoginScreenEvents();
  static EnterCodeScreenEvents enterCode = EnterCodeScreenEvents();
  static ReferralCheckScreenEvents referralCheck = ReferralCheckScreenEvents();
  static ChatScreenEvents chat = ChatScreenEvents();
  static MediaSelectionScreenEvents mediaSelection =
      MediaSelectionScreenEvents();
  static PhotoViewScreenEvents photoView = PhotoViewScreenEvents();
  static ProfileScreenEvents profile = ProfileScreenEvents();
  static PopupScreenEvents popupScreenEvents = PopupScreenEvents();
}
