import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/domain.dart';
import '../../application.dart';

@Injectable()
class CreatePdfThumbnailUseCase {
  CreatePdfThumbnailUseCase(this._cacheRepository);

  final CacheRepository _cacheRepository;

  Future<String> execute(Attachment pdf) async {
    final PdfDocument document = await PdfDocument.openFile(pdf.localFullPath!);
    final PdfPage page = await document.getPage(1);
    final PdfPageImage pageImage = await page.render();

    final ui.Image pdfImage = await pageImage.createImageDetached();
    final int originalWidth = pdfImage.width;
    final int originalHeight = pdfImage.height;

    // Calculate the new height while maintaining aspect ratio
    const int newWidth = 300;
    final int newHeight = (newWidth / originalWidth * originalHeight).round();

    // Create a new image with the desired width
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // Draw the scaled image onto the canvas
    final ui.Rect srcRect = ui.Rect.fromLTWH(
        0, 0, originalWidth.toDouble(), originalHeight.toDouble());
    final ui.Rect dstRect =
        ui.Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble());
    canvas.drawImageRect(pdfImage, srcRect, dstRect, ui.Paint());

    final ui.Image resizedImage =
        await recorder.endRecording().toImage(newWidth, newHeight);

    // Convert the resized image to bytes
    final ByteData? imgBytes = await resizedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final String placeholderName = '${const Uuid().v4()}.png';

    final Directory cache = await getApplicationCacheDirectory();
    final String imagePath = '${cache.path}/$placeholderName';
    final File pngFile = File(imagePath);

    pngFile.writeAsBytesSync(imgBytes!.buffer.asUint8List());

    Supabase.instance.client.storage
        .from('placeholders')
        .upload(placeholderName, File(imagePath));

    final String url = Supabase.instance.client.storage
        .from('placeholders')
        .getAuthenticatedUrl(placeholderName);

    await _cacheRepository.cacheFile(
      url: url,
      key: url,
      file: pngFile,
    );

    return url;
  }
}
