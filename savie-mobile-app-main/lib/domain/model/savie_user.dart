import 'package:freezed_annotation/freezed_annotation.dart';

part 'savie_user.freezed.dart';

@freezed
class SavieUser with _$SavieUser {
  const factory SavieUser({
    required String id,
    required String userId,
    required bool accessAllowed,
    required bool joinWaitlist,
    required bool notifyPro,
  }) = _SavieUser;

  const SavieUser._();
}
