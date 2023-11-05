import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_share_capp/core/exception/auth/authorization_exception.dart';

import '../../../core/util/result.dart';
import '../../../domain/auth/authorization_info.dart';
import '../../../infra/auth/fs_constants.dart';
import 'authorization_repository.dart';

final authorizationServiceProvider = Provider<AuthorizationService>(
  (ref) => AuthorizationService(ref),
);

class AuthorizationService {
  final Ref ref;

  AuthorizationService(this.ref);

  Stream<List<AuthorizationInfo>> getUsersStream({
    bool excludesAuthorizationAdmins = false,
    String? excludeUid,
  }) {
    final repo = ref.watch(authorizationRepositoryProvider);
    final stream = repo.getUsersStream(
        excludesAuthorizationAdmins: excludesAuthorizationAdmins,
        excludeUid: excludeUid);
    return stream;
  }

  Future<Result<void, AuthorizationException>> updateUserLicense(
      {required String adminUid,
      required String targetUid,
      required bool canUse}) async {
    final updatedUserData = {
      FsAuthorizations.allowReadObservationData: canUse,
      FsAuthorizations.allowWriteObservationData: canUse,
    };

    final repo = ref.watch(authorizationRepositoryProvider);
    return await repo.update(adminUid, targetUid, updatedUserData).then(
      (_) async {
        return Result.ok(null);
      },
      onError: (e) async {
        return Result.err(repo.buildException('failed authority updating.', e));
      },
    );
  }
}
