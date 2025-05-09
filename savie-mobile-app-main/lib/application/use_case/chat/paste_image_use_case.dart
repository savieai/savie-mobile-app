import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

@Injectable()
class PasteImageUseCase {
  Future<String?> execute() async {
    final Uint8List? bytes = await Pasteboard.image;

    if (bytes == null) {
      return null;
    }

    final Directory cacheDir = await getTemporaryDirectory();
    final String fileName = '${const Uuid().v4()}.png';
    final File imageFile = File('${cacheDir.path}/$fileName');
    imageFile.createSync();
    imageFile.writeAsBytesSync(bytes);

    return imageFile.path;
  }
}
