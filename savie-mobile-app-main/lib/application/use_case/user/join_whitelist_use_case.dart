import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class JoinWhitelistUseCase {
  JoinWhitelistUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<SavieUser?> execute() async {
    final SavieUser? user = _userRepository.getUser();
    if (user == null) {
      return null;
    }

    final bool result = await _userRepository.updateUser(
      user.copyWith(joinWaitlist: true),
    );

    if (result) {
      return _userRepository.fetchUser();
    }

    return null;
  }
}
