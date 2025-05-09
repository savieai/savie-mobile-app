import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import '../../application.dart';

@Injectable()
class NotifyAboutProUseCase {
  NotifyAboutProUseCase(
    this._userRepository,
    this._setProPopupDisplayedUseCase,
  );

  final UserRepository _userRepository;
  final SetProPopupDisplayedUseCase _setProPopupDisplayedUseCase;

  Future<bool> execute() async {
    final SavieUser? user = _userRepository.getUser();
    if (user == null) {
      return false;
    }

    final SavieUser updatedUser = user.copyWith(notifyPro: true);
    final bool result = await _userRepository.updateUser(updatedUser);

    if (!result) {
      return false;
    }

    final SavieUser? fetchedUser = await _userRepository.fetchUser();

    if (fetchedUser == null || !fetchedUser.notifyPro) {
      return false;
    } else {
      return _setProPopupDisplayedUseCase.execute();
    }
  }
}
