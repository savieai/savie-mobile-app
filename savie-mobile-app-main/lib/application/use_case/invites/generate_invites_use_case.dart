import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class CreateInvitesUseCase {
  CreateInvitesUseCase(this._invitesRepository);

  final InvitesRepository _invitesRepository;

  /// Creates up to 5 five invites if a user has less than 5
  Future<void> execute(int amount) async {
    for (int i = 0; i < amount; i++) {
      final Either<void, Invite> maybeInvite =
          await _invitesRepository.createInvite();

      if (maybeInvite.isLeft) {
        return;
      }
    }
  }
}
