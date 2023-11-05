import 'package:device_info_plus/device_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// usage:
/// ```
/// ProviderScope(
///   overrides: [
///     initDeviceInfoProvider(),
///   ],
///   child: ...
/// ),
/// ```
final deviceInfoProvider = Provider<DeviceInfo>(
  (ref) =>
      throw UnimplementedError('should overrideWithValue deviceInfoProvider'),
);

Future<Override> initDeviceInfoProvider() async {
  return deviceInfoProvider.overrideWithValue(await _DeviceUtil.buildInfo());
}

class _DeviceUtil {
  const _DeviceUtil._();

  static Future<DeviceInfo> buildInfo() async {
    final ret =
        await DeviceInfoPlugin().webBrowserInfo.then<DeviceInfo>((info) {
      final String appVersion = info.appVersion!.toLowerCase();
      final isAndroid = appVersion.contains('android');
      final isLinux = !isAndroid && appVersion.contains('linux');

      final isIOS =
          appVersion.contains('iphone') || appVersion.contains('ipad');
      final isMacOS = !isIOS && appVersion.contains('macintosh');

      final isWindows = appVersion.contains('windows');
      return DeviceInfo(
          isAndroid: isAndroid,
          isLinux: isLinux,
          isIOS: isIOS,
          isMacOS: isMacOS,
          isWindows: isWindows);
    });
    return ret;
  }
}

class DeviceInfo {
  DeviceInfo({
    isAndroid = false,
    isWindows = false,
    isIOS = false,
    isMacOS = false,
    isLinux = false,
  })  : _isAndroid = isAndroid,
        _isWindows = isWindows,
        _isIOS = isIOS,
        _isMacOS = isMacOS,
        _isLinux = isLinux;

  final bool _isAndroid;
  final bool _isWindows;
  final bool _isIOS;
  final bool _isMacOS;
  final bool _isLinux;

  bool get isAndroid => _isAndroid;
  bool get isWindows => _isWindows;
  bool get isIOS => _isIOS;
  bool get isMacOS => _isMacOS;
  bool get isLinux => _isLinux;

  bool get isDesktop => isWindows || isMacOS || isLinux;
  bool get isMobile => isAndroid || isIOS;
}
