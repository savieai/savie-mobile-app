import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class GetFavIconUrlSyncUseCase {
  GetFavIconUrlSyncUseCase(this._favIconRepository);

  final FavIconRepository _favIconRepository;

  String? execute(String url) => _favIconRepository.getIconUrlSync(url);
}
