import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/domain.dart';
import '../../application.dart';
import 'resize_image_use_case.dart';

@Injectable()
class CreateImageThumbnailUseCase {
  CreateImageThumbnailUseCase(
    this._cacheRepository,
    this._resizeImageUseCase,
  );

  final CacheRepository _cacheRepository;
  final ResizeImageUseCase _resizeImageUseCase;

  Future<String> execute(Attachment image) async {
    final String imagePath = image.localFullPath!;

    // Increase thumbnail size from 150 to 300 for better quality
    final Uint8List resizedThumbnail =
        await _resizeImageUseCase.execute(imagePath, 300);

    final String placeholderName =
        '${const Uuid().v4()}.${image.name.split('.').last}';

    final Directory tempDir = await getTemporaryDirectory();

    // Save the resized image (thumbnail) to a temporary file
    final String tempPath = '${tempDir.path}/thumbnail_$placeholderName';
    final File thumbnailFile = File(tempPath)
      ..writeAsBytesSync(resizedThumbnail);

    // Upload the thumbnail image to Supabase
    Supabase.instance.client.storage
        .from('placeholders')
        .upload(placeholderName, thumbnailFile);

    // Get the authenticated URL of the uploaded thumbnail
    final String url = Supabase.instance.client.storage
        .from('placeholders')
        .getAuthenticatedUrl(placeholderName);

    // Cache the thumbnail file
    await _cacheRepository.cacheFile(
      url: url,
      key: url,
      file: thumbnailFile,
    );

    // Return the URL of the thumbnail image
    return url;
  }
}
