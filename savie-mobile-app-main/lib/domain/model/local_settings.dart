import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_settings.freezed.dart';

@freezed
class LocalSettings with _$LocalSettings {
  const factory LocalSettings({
    required bool proPopupShown,
  }) = _LocalSettings;

  const LocalSettings._();

  static const LocalSettings empty = LocalSettings(proPopupShown: false);
}
