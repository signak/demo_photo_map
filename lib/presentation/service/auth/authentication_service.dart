import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/util/logger.dart';
import '../../../core/util/result.dart';
import '../../../domain/auth/auth_exception.dart';
import '../../../domain/auth/auth_state.dart';
import 'auth_state_service.dart';
import 'authenticator.dart';

final authenticationServiceProvider = Provider<AuthenticationService>(
  (ref) => throw UnimplementedError(
      'Should override authenticationServiceProvider.'),
);

class AuthenticationService {
  AuthenticationService(this.ref,
      {Authenticator? googleAuth, Authenticator? emailAuth})
      : _googleAuth = googleAuth,
        _emailAuth = emailAuth;
  final ProviderRef ref;
  final Authenticator? _googleAuth;
  final Authenticator? _emailAuth;

  Future<bool> initialized(
      {Duration timeout = const Duration(seconds: 10)}) async {
    final notifier = ref.read(authServiceStatusNotifierProvider);
    final completer = Completer<AuthServiceStatus>();
    final listener = notifier.stream.listen((e) {
      if (e == AuthServiceStatus.ready) {
        completer.complete(e);
      }
    });
    final status = await completer.future.timeout(
      timeout,
      onTimeout: () {
        logger.w('timeout auth service initializing.');
        return AuthServiceStatus.initializing;
      },
    );
    unawaited(listener.cancel());
    return status == AuthServiceStatus.ready;
  }

  Future<String?> signIn({String? email, String? password}) async {
    late final Result<String?, AuthException> user;

    if (email != null && password != null) {
      logger.i('emailProvider.signIn');
      user = await _emailAuth!.signIn(email: email, password: password);
    } else {
      logger.i('googleProvider.signIn');
      user = await _googleAuth!.signIn();
    }
    return user.when(
      ok: (uid) => uid,
      err: (e) => throw e,
    );
  }

  Future<void> signOut(AuthState? user) async {
    if (user == null) {
      return;
    }

    late final Result<void, AuthException> ret;
    if (user.provider == AuthProviderType.google) {
      logger.i('googleProvider.signOut');
      ret = await _googleAuth!.signOut();
    } else {
      ret = await _emailAuth!.signOut();
      logger.i('emailProvider.signOut');
    }

    ret.when(
      ok: (_) {},
      err: (e) => throw e,
    );
  }

  Future<void> reload() async {
    await ref.read(authStateNotifierProvider.notifier).reload();
  }

  Future<void> createNewAccount(String email, String password) async {
    final ret = await _emailAuth!.createNewAccount(email, password);
    ret.when(
      ok: (_) {},
      err: (e) => throw e,
    );
  }

  Future<void> sendEmailVerification(AuthState? user) async {
    final ret = await _emailAuth!.sendEmailVerification(user);
    ret.when(
      ok: (_) {},
      err: (e) => throw e,
    );
  }

  Future<void> resetPassword(String email) async {
    final ret = await _emailAuth!.resetPassword(email);
    ret.when(
      ok: (_) {},
      err: (e) => throw e,
    );
  }
}
