import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';
import '../../../presentation/presentation.dart';

@Injectable()
class ProcessSharingIntentStream {
  StreamSubscription<List<SharedMediaFile>> execute(final ChatCubit chatCubit) {
    return ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        if (Supabase.instance.client.auth.currentSession == null) {
          return;
        }

        for (final SharedMediaFile file in files) {
          switch (file.type) {
            case SharedMediaType.image:
            case SharedMediaType.video:
            case SharedMediaType.file:
              chatCubit.sendFile(file.path);
              break;
            case SharedMediaType.text:
            case SharedMediaType.url:
              chatCubit.sendMessage(
                textContents: <TextContent>[
                  TextContent.plainText(text: file.path),
                ],
              );
              break;
          }
        }
      },
    );
  }
}
