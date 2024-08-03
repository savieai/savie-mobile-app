import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class ApplyInviteUseCase {
  ApplyInviteUseCase(
    this._invitesRepository,
    this._userRepository,
  );

  final InvitesRepository _invitesRepository;
  final UserRepository _userRepository;

  Future<bool> execute(String code) async {
    final bool result = await _invitesRepository.applyInvite(code);
    if (result) {
      await _userRepository.fetchUser();
    }

    return result;
  }
}
