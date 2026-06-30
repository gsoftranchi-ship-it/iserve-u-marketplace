import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageOptimizerService {
  static Future<File?> convertToStandardWebP(
      File inputFile,
      ) async {
    try {
      // Read image bytes
      final Uint8List fileBytes =
      await inputFile.readAsBytes();

      // Decode image
      img.Image? decodedImage =
      img.decodeImage(fileBytes);

      if (decodedImage == null) {
        return null;
      }

      // Fix mobile camera rotation
      decodedImage =
          img.bakeOrientation(decodedImage);

      // Preserve aspect ratio
      img.Image resizedImage;

      if (decodedImage.width >= decodedImage.height) {
        resizedImage = img.copyResize(
          decodedImage,
          width: 1200,
          interpolation: img.Interpolation.linear,
        );
      } else {
        resizedImage = img.copyResize(
          decodedImage,
          height: 1200,
          interpolation: img.Interpolation.linear,
        );
      }

      // Convert to WEBP
      final Uint8List jpgBytes =
      Uint8List.fromList(
        img.encodeJpg(
          resizedImage,
          quality: 75,
        ),
      );

      final Directory tempDir =
      await getTemporaryDirectory();

      final String filePath =
          '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final File jpgFile =
      File(filePath);

      await jpgFile.writeAsBytes(
        jpgBytes,
      );

      return jpgFile;
    } catch (e) {
      debugPrint(
        'Image Optimizer Error: $e',
      );

      return null;
    }
  }
}