import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../core/util/logger.dart';
import '../../core/util/result.dart';
import '../../domain/auth/auth_exception.dart';
import '../../presentation/service/auth/auth_state_service.dart';
import '../../presentation/service/auth/authenticator.dart';
import 'auth_util.dart';
import 'fb_auth_exception.dart';

const int webSignInTimeoutSec = 300;

final firebaseGoogleAuthenticatorProvider = Provider<Authenticator>(
  (ref) => GoogleAuthenticator(ref),
);

class GoogleAuthenticator extends Authenticator {
  GoogleAuthenticator(this._ref);
  final Ref _ref;

  void awaitAuthenticationApplied() {
    logger.d('[GoogleAuthenticator] called awaitAuthenticationApplied');
    // wait for update of user
    AuthUtil.awaitAuthenticationApplied(_ref.read(authStateStreamProvider));
    // await _ref.read(firebaseAuthStateProvider.stream).first;
  }

  @override
  Future<Result<String?, AuthException>> signIn(
      {String? email, String? password}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (UniversalPlatform.isWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth
            .signInWithPopup(authProvider)
            .timeout(const Duration(seconds: webSignInTimeoutSec));

        awaitAuthenticationApplied();
        user = userCredential.user;
      } on FirebaseAuthException catch (e, st) {
        logger.e('sign in error on web', e, st);
        return Result.err(FbAuthException.onSignInWithCredential(e));
      } on TimeoutException catch (e, st) {
        logger.e('sign in timeout on web', e, st);
        return Result.err(FbAuthException.onSignInTimeout(e));
      } catch (e, st) {
        logger.e('Error occurred using Google Sign-In on web.', e, st);
        rethrow;
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          awaitAuthenticationApplied();
          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          return Result.err(FbAuthException.onSignInWithCredential(e));
        } catch (e, st) {
          logger.e('Error occurred using Google Sign-In.', e, st);
          rethrow;
        }
      }
    }

    if (user == null) {
      return Result.err(
          FbAuthException.unknownException(Exception('no user.')));
    }
    return Result.ok(user.uid);
  }

  @override
  Future<Result<void, AuthException>> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final isWeb = UniversalPlatform.isWeb;
    try {
      if (!isWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.err(FbAuthException.onSignOutWithCredential(e));
    } catch (e, st) {
      logger.e('Unknown error raised on signing out. (isWeb=$isWeb)', e, st);
      rethrow;
    }
  }
}
