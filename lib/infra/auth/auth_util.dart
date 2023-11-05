import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/util/logger.dart';

class AuthUtil {
  const AuthUtil._();

  static T? awaitAuthenticationApplied<T>(AsyncValue<T> asyncValue) {
    // wait for update of user
    final ret = asyncValue.maybeWhen<T?>(
      skipError: true,
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        return data;
      },
      orElse: () {
        return null;
      },
    );
    if (ret == null) {
      logger.e('[AuthUtil] failed awaiting on awaitAuthenticationApplied.');
    } else {
      logger.e(
          '[AuthUtil] complete awaiting on awaitAuthenticationApplied. ret=${ret.runtimeType}');
    }
    return ret;
  }
}
