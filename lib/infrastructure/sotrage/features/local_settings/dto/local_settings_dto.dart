import 'package:freezed_annotation/freezed_annotation.dart';

part 'local_settings_dto.freezed.dart';
part 'local_settings_dto.g.dart';

@freezed
class LocalSettingsDTO with _$LocalSettingsDTO {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory LocalSettingsDTO({
    required bool proPopupShown,
  }) = _LocalSettingsDTO;

  const LocalSettingsDTO._();

  factory LocalSettingsDTO.fromJson(Map<String, Object?> json) =>
      _$LocalSettingsDTOFromJson(json);
}
