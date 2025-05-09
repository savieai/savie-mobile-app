import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import 'generate_invites_use_case.dart';

@Injectable()
class GetInvitesUseCase {
  GetInvitesUseCase(
    this._invitesRepository,
    this._createInvitesUseCase,
  );

  final InvitesRepository _invitesRepository;
  final CreateInvitesUseCase _createInvitesUseCase;

  /// Gets all invites, created missing invites, if needed, to make 5 in total
  Future<Either<void, List<Invite>>> execute() async {
    final Either<void, List<Invite>> maybeInvites =
        await _invitesRepository.getInvites();

    if (maybeInvites.isLeft) {
      return const Left<void, List<Invite>>(null);
    }

    final List<Invite> invites = maybeInvites.right;
    if (invites.length >= 5) {
      return Right<void, List<Invite>>(invites);
    } else {
      await _createInvitesUseCase.execute(5 - invites.length);
      final Either<void, List<Invite>> updatedInvites =
          await _invitesRepository.getInvites();
      return updatedInvites.either(
        (_) {},
        (List<Invite> invites) => invites,
      );
    }
  }
}
