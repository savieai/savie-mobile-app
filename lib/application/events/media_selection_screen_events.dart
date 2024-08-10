import '../../domain/domain.dart';

class MediaSelectionScreenEvents {
  AppEvent get screenOpened =>
      const AppEvent('main.media_selection_screen.opened');

  AppEvent get filesClicked =>
      const AppEvent('main.media_selection_screen.files_tab.clicked');

  AppEvent get screenClosed =>
      const AppEvent('main.media_selection_screen.close');

  AppEvent get recentClicked =>
      const AppEvent('main.media_selection_screen.recent_button.clicked');

  AppEvent get cameraClicked =>
      const AppEvent('main.media_selection_screen.camera_button.clicked');

  AppEvent sendClicked({
    required AppEventMessageType type,
  }) =>
      AppEvent(
        'main.media_selection_screen.send_message_button.clicked',
        params: <String, Object>{
          'sent_message_type': type.key,
        },
      );
}
