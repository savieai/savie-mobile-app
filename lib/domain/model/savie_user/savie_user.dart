import 'package:freezed_annotation/freezed_annotation.dart';

part 'savie_user.freezed.dart';

@freezed
class SavieUser with _$SavieUser {
  const factory SavieUser({
    required String userId,
    required bool accessAllowed,
  }) = _SavieUser;
}
