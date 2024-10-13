import 'dart:io';

import 'package:gal/gal.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/domain.dart';
import '../../application.dart';

@Injectable()
class SaveImagesUseCase {
  SaveImagesUseCase(this._getFileUseCase);

  final GetFileUseCase _getFileUseCase;

  Future<void> execute(List<Attachment> attachments) async {
    await Future.wait(
      attachments.map(
        (Attachment a) async {
          final File file = await _getFileUseCase.execute(
            localFullPath: a.localFullPath,
            signedUrl: a.signedUrl,
            name: a.remoteStorageName ?? a.name,
          );

          if (file.existsSync()) {
            await Gal.putImage(file.path);
          }
        },
      ),
    );
  }
}
