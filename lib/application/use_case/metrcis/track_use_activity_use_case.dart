import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';

@Injectable()
class TrackUseActivityUseCase {
  TrackUseActivityUseCase(this._metrcisRepository);

  final MetrcisRepository _metrcisRepository;

  void execute(AppEvent appEvent) {
    final bool emailProvided = appEvent.params?.containsKey('email') ?? false;
    final String? email =
        Supabase.instance.client.auth.currentSession?.user.email;
    final bool emailAvailable = email != null;

    late final Map<String, Object>? updatedParams;

    if (!emailProvided && emailAvailable) {
      updatedParams =
          Map<String, Object>.of(appEvent.params ?? <String, Object>{})
            ..['email'] = email;
    } else {
      updatedParams = appEvent.params;
    }

    _metrcisRepository.log(
      AppEvent(appEvent.name, params: updatedParams),
    );
    
  }
}
