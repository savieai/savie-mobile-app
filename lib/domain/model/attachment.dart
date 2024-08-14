import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';

@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String name,
    required String? remoteUrl,
    required String? localUrl,
  }) = _Attachment;
}
