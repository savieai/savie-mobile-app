import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/domain.dart';
import '../../application.dart';

@Injectable()
class ShareFilesUseCase {
  ShareFilesUseCase(this._getFileUseCase);

  final GetFileUseCase _getFileUseCase;

  Future<void> execute(
    List<Attachment> attachments, {
    String? text,
  }) async {
    if (attachments.isEmpty && (text ?? '').isNotEmpty) {
      await Share.share(text ?? '');
      return;
    }

    await Share.shareXFiles(
      await Future.wait(
        attachments.map(
          (Attachment a) => _getFileUseCase
              .execute(
                localFullPath: a.localFullPath,
                signedUrl: a.signedUrl,
                name: a.remoteStorageName ?? a.name,
              )
              .then((File f) => XFile(f.path)),
        ),
      ),
      text: (text ?? '').isEmpty ? null : text,
    );
  }
}
