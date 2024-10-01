import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

@Injectable()
class ResizeImageUseCase {
  Future<Uint8List> execute(String imagePath, int maxSide) async {
    // Use compute to offload the image processing to a background thread
    final Uint8List result = await compute(
      processImage,
      <String, dynamic>{
        'imagePath': imagePath,
        'maxSide': maxSide,
      },
    );
    return result;
  }
}

Future<Uint8List> processImage(Map<String, dynamic> data) async {
  final String imagePath = data['imagePath'] as String;
  final int maxSide = data['maxSide'] as int;

  // Load the image from the file
  final File originalFile = File(imagePath);
  final img.Image? image = img.decodeImage(originalFile.readAsBytesSync());

  if (image != null) {
    // Resize the image if its width is greater than 1080px
    final img.Image resizedImage = img.copyResize(
      image,
      width: image.width > maxSide ? maxSide : image.width,
    );

    // Compress the resized image to reduce file size
    final Uint8List compressedBytes = Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: 85), // Adjust quality as needed
    );

    return compressedBytes;
  } else {
    throw Exception('Failed to load image: $imagePath');
  }
}
