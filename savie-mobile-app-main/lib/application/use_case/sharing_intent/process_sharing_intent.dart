import 'package:injectable/injectable.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../domain/model/model.dart';
import '../../../main.dart';
import '../../../presentation/presentation.dart';

@Injectable()
class ProcessSharingIntent {
  Future<void> execute(final ChatCubit chatCubit) async {
    if (wasInitiallyLoggedIn) {
      await ReceiveSharingIntent.instance.getInitialMedia().then(
        (List<SharedMediaFile> files) {
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
}
