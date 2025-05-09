import 'package:freezed_annotation/freezed_annotation.dart';

part 'favicon_info.freezed.dart';

@freezed
class FaviconInfo with _$FaviconInfo {
  const factory FaviconInfo({
    required String url,
    required bool isSvg,
  }) = _FaviconInfo;

  const FaviconInfo._();
}
