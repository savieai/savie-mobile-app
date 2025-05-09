import '../../domain/domain.dart';

class ChatScreenEvents {
  AppEvent get screenOpened => const AppEvent('main.chat_screen.opened');

  AppEvent get mediaButtonClicked =>
      const AppEvent('main.chat_screen.add_media_button.clicked');

  AppEvent get voiceButtonClicked => const AppEvent(
        'main.chat_screen.start_voice_recording_button.clicked',
        params: <String, String>{'sent_message_type': 'voice'},
      );

  AppEvent get searchButtonPressed =>
      const AppEvent('general.header.search_button.clicked');

  AppEvent get profileButtonClicked =>
      const AppEvent('general.header.profile_button.clicked');

  AppEvent get sendButtonClicked => const AppEvent(
        'main.chat_screen.send_message_button.clicked',
        params: <String, String>{'sent_message_type': 'text'},
      );

  AppEvent voiceButtonReleased({
    required Duration duration,
  }) =>
      AppEvent(
        'main.chat_screen.send_message_button.clicked',
        params: <String, Object>{
          'sent_message_type': 'voice',
          'duration': duration.inSeconds,
        },
      );

  AppEvent voiceCancelClicked({
    required Duration duration,
  }) =>
      AppEvent(
        'main.chat_screen.cancel_recording_button.clicked',
        params: <String, Object>{
          'duration': duration.inSeconds,
        },
      );

  AppEvent voiceLocked({
    required Duration duration,
  }) =>
      AppEvent(
        'main.chat_screen.record_voice_locked_button.clicked',
        params: <String, Object>{
          'locked_in': duration.inSeconds,
        },
      );

  AppEvent audioPlayed({
    required String messageId,
    required Duration duration,
  }) =>
      AppEvent(
        'main.chat_screen.message.play',
        params: <String, Object>{
          'message_id': messageId,
          'duration': duration.inSeconds,
          'message_type': 'voice',
        },
      );

  AppEvent audioPaused({
    required String messageId,
    required Duration duration,
    required Duration pausedAt,
  }) =>
      AppEvent(
        'main.chat_screen.message.pause',
        params: <String, Object>{
          'message_id': messageId,
          'duration': duration.inSeconds,
          'paused_at': pausedAt.inSeconds,
          'message_type': 'voice',
        },
      );

  AppEvent audioFinished({
    required String messageId,
    required Duration duration,
  }) =>
      AppEvent(
        'main.chat_screen.message.ended',
        params: <String, Object>{
          'message_id': messageId,
          'duration': duration.inSeconds,
          'message_type': 'voice',
        },
      );

  AppEvent attachmentClicked({
    required String messageId,
    required AppEventMessageType type,
  }) =>
      AppEvent(
        'main.chat_screen.message.view',
        params: <String, Object>{
          'message_id': messageId,
          'message_type': type.key,
        },
      );

  AppEvent linkClicked({
    required String messageId,
    required AppEventMessageType type,
  }) =>
      AppEvent(
        'main.chat_screen.message.clicked_link',
        params: <String, Object>{
          'message_id': messageId,
          'message_type': type.key,
        },
      );
}
