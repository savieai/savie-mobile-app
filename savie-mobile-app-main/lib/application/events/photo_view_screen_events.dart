import '../../domain/domain.dart';

class PhotoViewScreenEvents {
  AppEvent screenOpened({
    required String messageId,
    required AppEventMessageType type,
  }) =>
      AppEvent(
        'main.photo_view_screen.opened',
        params: <String, String>{
          'message_id': messageId,
          'message_type': type.key,
        },
      );

  AppEvent swipeRight({
    required String messageId,
    required AppEventMessageType type,
  }) =>
      AppEvent(
        'main.photo_view_screen.swipe_right',
        params: <String, String>{
          'message_id': messageId,
          'message_type': type.key,
        },
      );

  AppEvent swipeLeft({
    required String messageId,
    required AppEventMessageType type,
  }) =>
      AppEvent(
        'main.photo_view_screen.swipe_left',
        params: <String, String>{
          'message_id': messageId,
          'message_type': type.key,
        },
      );
}
