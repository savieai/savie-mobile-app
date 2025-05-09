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
  // We'll still keep the maxSide parameter for compatibility
  // but won't use it for resizing
  // final int maxSide = data['maxSide'] as int;

  // Load the image from the file
  final File originalFile = File(imagePath);
  final img.Image? image = img.decodeImage(originalFile.readAsBytesSync());

  if (image != null) {
    // No longer resizing the image to maintain original quality
    // Instead, we'll just use the original image
    
    // Check if the image is JPEG or another format
    final String extension = imagePath.split('.').last.toLowerCase();
    
    if (extension == 'jpg' || extension == 'jpeg') {
      // Use highest quality (100) for JPEG
      return Uint8List.fromList(
        img.encodeJpg(image, quality: 100),
      );
    } else {
      // Use PNG for better quality on other formats
      return Uint8List.fromList(
        img.encodePng(image),
      );
    }
  } else {
    // If we can't decode the image, just return the original bytes
    return originalFile.readAsBytesSync();
  }
}
