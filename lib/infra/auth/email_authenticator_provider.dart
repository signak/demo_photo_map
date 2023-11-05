import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/util/logger.dart';
import '../../core/util/result.dart';
import '../../domain/auth/auth_exception.dart';
import '../../domain/auth/auth_state.dart';
import '../../presentation/service/auth/auth_state_service.dart';
import '../../presentation/service/auth/authenticator.dart';
import 'auth_util.dart';
import 'fb_auth_exception.dart';
import 'firebase_auth_state.dart';

const int webSignInTimeoutSec = 30;

final firebaseEmailAuthenticatorProvider = Provider<Authenticator>(
  (ref) => EmailAuthenticator(ref),
);

class EmailAuthenticator extends Authenticator {
  EmailAuthenticator(this._ref);
  final Ref _ref;

  void awaitAuthenticationApplied() {
    logger.d('[EmailAuthenticator] called awaitAuthenticationApplied');
    // wait for update of user
    AuthUtil.awaitAuthenticationApplied(_ref.read(authStateStreamProvider));
    // await _ref.read(firebaseAuthStateProvider.stream).first;
  }

  @override
  Future<Result<String?, AuthException>> signIn(
      {String? email, String? password}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      final UserCredential userCredential = await auth
          .signInWithEmailAndPassword(email: email!, password: password!)
          .timeout(const Duration(seconds: webSignInTimeoutSec));

      awaitAuthenticationApplied();
      user = userCredential.user;
    } on FirebaseAuthException catch (e, st) {
      logger.e('error on sign in with email', e, st);
      return Result.err(FbAuthException.onSignInWithCredential(e));
    } on TimeoutException catch (e, st) {
      logger.e('timeout on sign in with email', e, st);
      return Result.err(FbAuthException.onSignInTimeout(e));
    } catch (e, st) {
      logger.e('Error occurred using Email/Password Sign-In', e, st);
      rethrow;
    }

    if (user == null) {
      return Result.err(
          FbAuthException.unknownException(Exception('no user.')));
    }

    return Result.ok(user.uid);
  }

  @override
  Future<Result<void, AuthException>> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.err(FbAuthException.onSignOutWithCredential(e));
    } catch (e, st) {
      logger.e('Unknown error raised on signing out.', e, st);
      rethrow;
    }
  }

  @override
  Future<Result<String?, AuthException>> createNewAccount(
      String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      awaitAuthenticationApplied();

      user = userCredential.user;
    } on FirebaseAuthException catch (e, st) {
      logger.e('error on create new account with email', e, st);
      return Result.err(FbAuthException.onCreateUserWithEmailAndPassword(e));
    } on TimeoutException catch (e, st) {
      logger.e('timeout on create new account with email', e, st);
      return Result.err(FbAuthException.onSignInTimeout(e));
    } catch (e, st) {
      logger.e('Error occurred using CreateUserWithEmailAndPassword', e, st);
      rethrow;
    }

    if (user == null) {
      return Result.err(
          FbAuthException.unknownException(Exception('failed user creation.')));
    }

    await user.sendEmailVerification();

    return Result.ok(user.uid);
  }

  @override
  Future<Result<void, AuthException>> sendEmailVerification(
      AuthState? user) async {
    final rawUser = (user as FirebaseAuthState).rawUser;

    if (rawUser == null) {
      return Result.err(
          FbAuthException.unknownException(Exception('no user.')));
    }

    await rawUser.sendEmailVerification();

    return Result.ok(null);
  }

  @override
  Future<Result<void, AuthException>> resetPassword(String email) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth
          .sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: webSignInTimeoutSec));
      return Result.ok(null);
    } on FirebaseAuthException catch (e, st) {
      logger.e('sign in error on web', e, st);
      return Result.err(FbAuthException.onSendPasswordResetEmail(e));
    } on TimeoutException catch (e, st) {
      logger.e('sign in timeout on web', e, st);
      return Result.err(FbAuthException.onSignInTimeout(e));
    } catch (e, st) {
      logger.e('Error occurred using send password reset email.', e, st);
      rethrow;
    }
  }
}
