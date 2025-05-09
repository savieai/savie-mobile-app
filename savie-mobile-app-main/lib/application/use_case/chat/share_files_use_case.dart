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
    String? plainText,
  }) async {
    if (attachments.isEmpty && (plainText ?? '').isNotEmpty) {
      await Share.share(plainText!);
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
      text: (plainText ?? '').isEmpty ? null : plainText,
    );
  }
}
