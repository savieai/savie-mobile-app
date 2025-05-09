import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';

@Injectable()
class GetFavIconUrlUseCase {
  GetFavIconUrlUseCase(this._favIconRepository);

  final FavIconRepository _favIconRepository;

  Future<String?> execute(String url) => _favIconRepository.getIconUrl(url);
}
