import 'dart:typed_data';

import 'package:exif/exif.dart' as exif;
import 'package:exif/exif.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class ExifInfo {
  ExifInfo(this.width, this.height, this.coordinate, this.altitude,
      this.createdAt, this.jsonText);

  final int? width;
  final int? height;
  final LatLng? coordinate;

  /// iOSの場合は標高/海抜高度（らしい？）
  /// Androidの場合は楕円体高/GPS高度なので、標高を出すにはその地点のジオイド高を取得してマイナスする必要がある
  final double? altitude;

  final DateTime? createdAt;
  final String jsonText;
}

class ExifUtil {
  ExifUtil._();
  static Future<ExifInfo> getExifInfoFromXFile(XFile file) async {
    return await file.readAsBytes().then((bytes) async {
      return getExifInfo(bytes);
    });
  }

  static Future<ExifInfo> getExifInfo(List<int> bytes) async {
    final exifMap = await exif.readExifFromBytes(bytes);

    final int? width = exifMap['EXIF ExifImageWidth']?.values.firstAsInt();
    final int? height = exifMap['EXIF ExifImageLength']?.values.firstAsInt();
    final double? latitude = _dmsToDecimal(exifMap['GPS GPSLatitude']?.values);
    final double? longitude =
        _dmsToDecimal(exifMap['GPS GPSLongitude']?.values);
    final double? altitude =
        exifMap['GPS GPSAltitude']?.values.firstAsInt() as double?;
    final DateTime? createdAt =
        _parseDateTime(exifMap['EXIF DateTimeOriginal']?.printable);
    final jsonString = _toJsonString(exifMap);

    return ExifInfo(
        width,
        height,
        (latitude != null && longitude != null)
            ? LatLng(latitude, longitude)
            : null,
        altitude,
        createdAt,
        jsonString);
  }

  static double? _dmsToDecimal(dynamic dms) {
    if (dms == null || dms is! IfdRatios) return null;

    final values = dms.toList();
    final d = (values[0] as Ratio).toDouble();
    final m = (values[1] as Ratio).toDouble();
    final s = (values[2] as Ratio).toDouble();

    final ret = d + (m / 60) + (s / 3600);
    return ret;
  }

  static Future<Size> getSizeFromXFile(XFile file) async {
    return await file.readAsBytes().then((bytes) async {
      return getSize(bytes);
    });
  }

  static Size getSize(Uint8List bytes) {
    return ImageSizeGetter.getSize(MemoryInput(bytes));
  }

  static Future<String> getJsonFromXFile(XFile file) async {
    return await file.readAsBytes().then((bytes) async {
      return await getJson(bytes);
    });
  }

  static Future<String> getJson(List<int> bytes) async {
    final exifMap = await exif.readExifFromBytes(bytes);
    return _toJsonString(exifMap);
  }

  static String _toJsonString(Map<String, IfdTag> data) {
    final List<String> buf = [];
    data.forEach((key, value) {
      buf.add('"$key":"$value"');
    });

    // logger.d(buf.join('\n'));

    return '{${buf.join(",")}}';
  }

  static final _dateFormatter = DateFormat("y:M:d HH:mm:ss");

  static DateTime? _parseDateTime(String? text) {
    if (text == null) return null;
    return _dateFormatter.parseStrict(text);
  }
}

/*
"GPS GPSLatitude":"[37, 34, 472519/10000]"
"GPS GPSLongitudeRef":"E"
"GPS GPSLongitude":"[140, 41, 58737/10000]"
"GPS GPSAltitude":"615"
"GPS GPSTimeStamp":"[4, 28, 58]"
"GPS GPSProcessingMethod":"ASCII"
"GPS GPSDate":"2022:10:24"
"Image GPSInfo":"664"
"Thumbnail Compression":"JPEG (old-style)"
"Thumbnail XResolution":"72"
"Thumbnail YResolution":"72"
"Thumbnail ResolutionUnit":"Pixels/Inch"
"Thumbnail JPEGInterchangeFormat":"996"
"Thumbnail JPEGInterchangeFormatLength":"11533"
"EXIF ExposureTime":"1/1154"
"EXIF FNumber":"2"
"EXIF ExposureProgram":"Unidentified"
"EXIF ISOSpeedRatings":"101"
"EXIF ExifVersion":"0220"
"EXIF DateTimeOriginal":"2022:10:24 13:28:59"
"EXIF DateTimeDigitized":"2022:10:24 13:28:59"
"EXIF ComponentsConfiguration":"YCbCr"
"EXIF ShutterSpeedValue":"10173/1000"
"EXIF ApertureValue":"2"
"EXIF BrightnessValue":"0"
"EXIF MeteringMode":"Average"
"EXIF Flash":"Flash did not fire, compulsory flash mode"
"EXIF FocalLength":"283/100"
"EXIF SubSecTime":"179307"
"EXIF SubSecTimeOriginal":"179307"
"EXIF SubSecTimeDigitized":"179307"
"EXIF FlashPixVersion":"0100"
"EXIF ColorSpace":"sRGB"
"EXIF ExifImageWidth":"1600"
"EXIF ExifImageLength":"1200"
"Interoperability InteroperabilityIndex":"R98"
"Interoperability InteroperabilityVersion":"[48, 49, 48, 48]"
"EXIF InteroperabilityOffset":"633"
"EXIF SensingMethod":"One-chip color area"
"EXIF SceneType":"Directly Photographed"
"EXIF ExposureMode":"Auto Exposure"
"EXIF WhiteBalance":"Auto"
"EXIF FocalLengthIn35mmFilm":"3"
"EXIF SceneCaptureType":"Standard"
"JPEGThumbnail":""
*/
