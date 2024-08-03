import 'package:either_dart/either.dart';

import '../model/invite/invite.dart';

abstract class InvitesRepository {
  Future<Either<void, List<Invite>>> getInvites();
  Future<Either<void, Invite>> createInvite();
  Future<bool> applyInvite(String code);
}
