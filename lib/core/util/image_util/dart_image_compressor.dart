import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../logger.dart';
import 'image_util.dart';

class DartImageCompressor {
  const DartImageCompressor._();

  static Future<Uint8List?> compress(XFile file,
      {int quantity = 100, int? maxWidth, int? maxHeight}) async {
    try {
      // decode
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return null;
      }

      // calc image size
      final width = image.data!.width;
      final height = image.data!.height;
      Size size = ImageUtil.calculateSizeOfDownScaledImage(
          Size(width.toDouble(), height.toDouble()),
          maxWidth?.toDouble(),
          maxHeight?.toDouble());

      // resize image
      late final img.Image resizedImage;
      if (maxHeight == null && maxWidth == null) {
        resizedImage = image;
      } else {
        resizedImage = img.copyResize(image,
            width: size.width.toInt(),
            height: size.height.toInt(),
            interpolation: img.Interpolation.cubic);
      }

      // encode
      final encodedBytes = img.encodeJpg(resizedImage, quality: quantity);
      return encodedBytes;
    } catch (e, st) {
      logger.e('failed image compression by image package.', e, st);
      return null;
    }
  }
}
