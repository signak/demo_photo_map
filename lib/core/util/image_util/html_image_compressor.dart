import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

import '../logger.dart';
import 'image_util.dart';

class HtmlImageCompressor {
  const HtmlImageCompressor._();

  static Future<Uint8List?> compress(XFile file,
      {int quantity = 100, int? maxWidth, int? maxHeight}) async {
    try {
      final html.ImageElement imageElement = await _loadImage(file.path);
      final html.CanvasElement canvas =
          _getCanvas(imageElement, maxWidth: maxWidth, maxHeight: maxHeight);
      final imageBytes =
          await _convertCanvasToUint8List(file, canvas, quantity);
      return imageBytes;
    } catch (e, st) {
      logger.e('failed image compression by html.canvas.', e, st);
      return null;
    }
  }

  /// function that loads the blobUrl into an imageElement
  static Future<html.ImageElement> _loadImage(String blobUrl) {
    final Completer<html.ImageElement> imageLoadCompleter =
        Completer<html.ImageElement>();
    final html.ImageElement imageElement = html.ImageElement();
    // ignore: unsafe_html
    imageElement.src = blobUrl;

    imageElement.onLoad.listen((html.Event event) {
      imageLoadCompleter.complete(imageElement);
    });
    imageElement.onError.listen((html.Event event) {
      const String exception = 'Error while loading image.';
      imageElement.remove();
      imageLoadCompleter.completeError(exception);
    });
    return imageLoadCompleter.future;
  }

  /// Draws image to a canvas
  static html.CanvasElement _getCanvas(html.ImageElement source,
      {int? maxWidth, int? maxHeight}) {
    final Size newImageSize = ImageUtil.calculateSizeOfDownScaledImage(
        Size(source.width!.toDouble(), source.height!.toDouble()),
        maxWidth?.toDouble(),
        maxHeight?.toDouble());
    final html.CanvasElement canvas = html.CanvasElement();
    canvas.width = newImageSize.width.toInt();
    canvas.height = newImageSize.height.toInt();
    final html.CanvasRenderingContext2D context = canvas.context2D;
    if (maxHeight == null && maxWidth == null) {
      context.drawImage(source, 0, 0);
    } else {
      context.drawImageScaled(source, 0, 0, canvas.width!, canvas.height!);
    }
    return canvas;
  }

  /// function that converts a canvas element to Uint8List
  /// [imageQuality] is only supported for jpeg and webp images.
  static Future<Uint8List?> _convertCanvasToUint8List(
      XFile originalFile, html.CanvasElement canvas, int? imageQuality) async {
    final double calculatedImageQuality =
        (min(imageQuality ?? 100, 100)) / 100.0;
    final html.Blob blob =
        await canvas.toBlob(originalFile.mimeType, calculatedImageQuality);
    return _blobToUint8List(blob);
  }

  static Future<Uint8List?> _blobToUint8List(html.Blob blob) async {
    final r = html.FileReader();
    r.readAsArrayBuffer(blob);
    final blobLoadingCompleter = Completer<bool>();

    Uint8List? ret;
    r.onLoadEnd.listen((e) {
      final data = r.result;
      logger.d(data?.runtimeType);
      ret = _toUint8List(data);
      blobLoadingCompleter.complete(ret != null);
    }, onError: (e, st) {
      logger.d('failed blob loading.', e, st);
      blobLoadingCompleter.complete(false);
    });

    return await blobLoadingCompleter.future.then<Uint8List?>((_) => ret);
  }

  static Uint8List? _toUint8List(Object? data) {
    if (data == null) {
      return null;
    } else if (data is Uint8List) {
      return data;
    }

    if (data is! List || data.isEmpty) {
      return null;
    }

    List<int>? list;
    if (data is List<int>) {
      list = data;
    } else {
      try {
        list = data.map((e) => e as int).toList();
      } catch (_) {
        return null;
      }
    }

    try {
      return Uint8List.fromList(list);
    } catch (_) {
      return null;
    }
  }
}
