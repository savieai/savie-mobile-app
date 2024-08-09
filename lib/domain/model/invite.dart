import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite.freezed.dart';

@freezed
class Invite with _$Invite {
  const factory Invite({
    required String code,
    required bool isUsed,
  }) = _Invite;

  const Invite._();
}

extension InviteIterableX on Iterable<Invite> {
  Invite? get firstAvailableOrNull => firstWhereOrNull((Invite i) => !i.isUsed);
  int get numOfAvailable => where((Invite i) => !i.isUsed).length;
}
