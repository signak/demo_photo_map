import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/exception/auth/authorization_exception.dart';
import '../../../domain/auth/authorization_info.dart';

final authorizationRepositoryProvider = Provider<AuthorizationRepository>(
  (ref) => throw UnimplementedError(
      'should override authorizationRepositoryProvider'),
);

abstract class AuthorizationRepository {
  Future<void> update(
      String updatedBy, String targetUid, Map<String, dynamic> newData);

  Future<AuthorizationInfo> by(String uid, String email);

  Stream<List<AuthorizationInfo>> getUsersStream(
      {bool excludesAuthorizationAdmins = false, String? excludeUid});

  AuthorizationException buildException(String message, dynamic error,
      {StackTrace? stackTrace});
}
