import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'dart_image_compressor.dart';
import 'html_image_compressor.dart';

enum CompressorType {
  htmlCanvas,
  imagePlugin,
}

class ImageUtil {
  const ImageUtil._();

  static Future<Uint8List?> compress(CompressorType compressorType, XFile file,
      {int quantity = 100, int? maxWidth, int? maxHeight}) async {
    if (compressorType == CompressorType.htmlCanvas) {
      return await HtmlImageCompressor.compress(file,
          quantity: quantity, maxWidth: maxWidth, maxHeight: maxHeight);
    } else {
      return await DartImageCompressor.compress(file,
          quantity: quantity, maxWidth: maxWidth, maxHeight: maxHeight);
    }
  }

  /// a function that calculates the size of the downScaled image.<br/>
  /// [imageWidth] is the width of the image<br/>
  /// [imageHeight] is the height of  the image<br/>
  /// [maxWidth] is the maximum width of the scaled image<br/>
  /// [maxHeight] is the maximum height of the scaled image
  static Size calculateSizeOfDownScaledImage(
      Size imageSize, double? maxWidth, double? maxHeight) {
    final double widthFactor =
        maxWidth != null ? imageSize.width / maxWidth : 1;
    final double heightFactor =
        maxHeight != null ? imageSize.height / maxHeight : 1;
    final double resizeFactor = math.max(widthFactor, heightFactor);
    return resizeFactor > 1 ? imageSize ~/ resizeFactor : imageSize;
  }

  /// get image as Uint8List from assets.<br/>
  /// [id] is asset resource identifier.
  /// (ex. 'assets/assets/image/sample.jpg')
  static Future<Uint8List> getImageBytesFromAssets(String id) async {
    final data = await rootBundle.load(id);
    return data.buffer.asUint8List();
  }
}
