import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'logger.dart';

/// usage:
/// ```
/// ProviderScope(
///   overrides: [
///     initVersionInfoProvider(),
///   ],
///   child: ...
/// ),
/// ```
final versionInfoProvider = Provider<PackageInfo>(
  (ref) =>
      throw UnimplementedError('should overrideWithValue versionInfoProvider'),
);

Future<Override> initVersionInfoProvider(
    {bool shouldOutputVersionsToLog = false}) async {
  final info = await _VersionUtil.getInfo();
  if (shouldOutputVersionsToLog) {
    logger.i(info.toString());
  }
  return versionInfoProvider.overrideWithValue(info);
}

class _VersionUtil {
  const _VersionUtil._();

  static Future<PackageInfo> getInfo() async {
    return await PackageInfo.fromPlatform();
  }
}
