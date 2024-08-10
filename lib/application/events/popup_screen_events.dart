import '../../domain/domain.dart';

// TODO: provide type and trigger

class PopupScreenEvents {
  AppEvent get screenOpened => const AppEvent(
        'main.popup.opened',
        params: <String, String>{
          'trigger': 'give_savie_access',
          'popup_type': 'referal_code',
        },
      );

  AppEvent get screenClosed => const AppEvent(
        'main.popup.opened',
        params: <String, String>{
          'trigger': 'give_savie_access',
          'popup_type': 'referal_code',
        },
      );

  AppEvent get copyClicked => const AppEvent(
        'main.popup.copy',
        params: <String, String>{
          'trigger': 'give_savie_access',
          'popup_type': 'referal_code',
        },
      );

  AppEvent get shareClicked => const AppEvent(
        'main.popup.share_button.clicked',
        params: <String, String>{
          'trigger': 'give_savie_access',
          'popup_type': 'referal_code',
        },
      );
}
