import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/util/logger.dart';
import '../presentation/service/auth/auth_state_service.dart';
import 'routes.dart';

typedef RouteGuard = String? Function(
  BuildContext context,
  Ref ref,
  GoRouterState state,
  AuthStateForGuard auth, {
  String? redirectPath,
});

String _namedLocation(
  BuildContext context,
  Ref ref,
  String name, {
  Map<String, String> params = const <String, String>{},
  Map<String, dynamic> queryParams = const <String, dynamic>{},
}) {
  final GoRouter router = GoRouter.of(context);
  return router.routeInformationParser.configuration
      .namedLocation(name, params: params, queryParams: queryParams);
}

bool _isAuthenticated(Ref ref, AuthStateForGuard auth) {
  // final authState = ref.read(authStateNotifierProvider);
  // final isSignedIn = (authState == null) ? false : authState.isSignedIn;

  return auth.signedIn;
}

bool _isSystemAdmin(Ref ref, AuthStateForGuard auth) {
  // final authState = ref.read(authStateNotifierProvider);
  // final isSignedIn = (authState == null) ? false : authState.isSignedIn;
  // final isAdmin = (authState == null) ? false : authState.isSystemAdmin;

  return auth.signedIn && auth.emailVerified && auth.systemAdmin;
}

bool _isAuthAdmin(Ref ref, AuthStateForGuard auth) {
  // final authState = ref.read(authStateNotifierProvider);
  // final isSignedIn = (authState == null) ? false : authState.isSignedIn;
  // final isAdmin = (authState == null) ? false : authState.isSystemAdmin;

  return auth.signedIn && auth.emailVerified && auth.authAdmin;
}

bool _canRead(Ref ref, AuthStateForGuard auth) {
  // final authState = ref.read(authStateNotifierProvider);
  // final isSignedIn = (authState == null) ? false : authState.isSignedIn;
  // final canRead = (authState == null) ? false : authState.canRead;

  return auth.signedIn && auth.emailVerified && auth.canRead;
}

bool _canWrite(Ref ref, AuthStateForGuard auth) {
  // final authState = ref.read(authStateNotifierProvider);
  // final isSignedIn = (authState == null) ? false : authState.isSignedIn;
  // final canWrite = (authState == null) ? false : authState.canWrite;

  return auth.signedIn && auth.emailVerified && auth.canWrite;
}

String _defaultHomePath(BuildContext context, Ref ref, GoRouterState state) {
  try {
    return _namedLocation(
      context,
      ref,
      ReleaseRoutes.home.name,
    );
  } catch (e, st) {
    logger.w('failed home location finding.', e, st);
    return ReleaseRoutes.home.path;
  }
}

String _defaultSignInPath(BuildContext context, Ref ref, GoRouterState state) {
  try {
    return _namedLocation(
      context,
      ref,
      ReleaseRoutes.signIn.name,
    );
  } catch (e, st) {
    logger.w('[Guard] failed sign-in location finding.', e, st);
    return ReleaseRoutes.signIn.path;
  }
}

class AuthStateForGuard {
  AuthStateForGuard(this.signedIn, this.uid, this.provider, this.emailVerified,
      this.canRead, this.canWrite, this.authAdmin, this.systemAdmin);
  final bool signedIn;
  final String? uid;
  final String? provider;
  final bool emailVerified;
  final bool canRead;
  final bool canWrite;
  final bool authAdmin;
  final bool systemAdmin;
}

String? combineGuard(
  BuildContext context,
  GoRouterState state,
  Ref ref,
  List<RouteGuard> guards, {
  List<String?>? redirectPaths,
}) {
  // logger.d('called combineGuard');
  final authState = ref.read(authStateNotifierProvider);
  // logger.d(
  //     'auth.state: uid:${authState?.uid}, singedIn:${authState?.isSignedIn}, '
  //     'provider:${authState?.provider}, emailVerified:${authState?.emailVerified}, '
  //     'canRead:${authState?.canRead}');
  // String? notReadyRedirectTo = _rejectAuthServiceNotInitialized(context, ref);
  // if (notReadyRedirectTo != null) {
  //   return notReadyRedirectTo;
  // }

  final auth = AuthStateForGuard(
    authState?.isSignedIn ?? false,
    authState?.uid,
    authState?.provider.toString(),
    authState?.emailVerified ?? false,
    authState?.canRead ?? false,
    authState?.canWrite ?? false,
    authState?.isAuthorizationAdmin ?? false,
    authState?.isSystemAdmin ?? false,
  );

  for (int i = 0; i < guards.length; i++) {
    final guard = guards[i];
    final redirectPath = (redirectPaths == null) ? null : redirectPaths[i];
    final redirectTo =
        guard(context, ref, state, auth, redirectPath: redirectPath);
    if (redirectTo != null) {
      return redirectTo;
    }
  }
  return null;
}

// String? _rejectAuthServiceNotInitialized(BuildContext context, Ref ref) {
//   final status = ref.read(authServiceStatusProvider);
//   logger.d('guard $status');
//   if (status == AuthServiceStatus.initializing) {
//     return Routes.loading.path;
//   }
//   return null;
// }

String? rejectNotAuthenticated(
    BuildContext context, Ref ref, GoRouterState state, AuthStateForGuard auth,
    {String? redirectPath}) {
  if (_isAuthenticated(ref, auth)) {
    return null;
  } else {
    return _defaultSignInPath(context, ref, state);
  }
}

String? rejectAuthenticated(
  BuildContext context,
  Ref ref,
  GoRouterState state,
  AuthStateForGuard auth, {
  String? redirectPath,
}) {
  if (!_isAuthenticated(ref, auth)) {
    return (redirectPath == null)
        ? _defaultHomePath(context, ref, state)
        : redirectPath;
  } else {
    return null;
  }
}

String? rejectNotAdministrator(
  BuildContext context,
  Ref ref,
  GoRouterState state,
  AuthStateForGuard auth, {
  String? redirectPath,
}) {
  if (!_isSystemAdmin(ref, auth)) {
    return (redirectPath == null)
        ? _defaultHomePath(context, ref, state)
        : redirectPath;
  } else {
    return null;
  }
}

String? rejectNotAuthorizationAdmin(
  BuildContext context,
  Ref ref,
  GoRouterState state,
  AuthStateForGuard auth, {
  String? redirectPath,
}) {
  if (!_isAuthAdmin(ref, auth)) {
    return (redirectPath == null)
        ? _defaultHomePath(context, ref, state)
        : redirectPath;
  } else {
    return null;
  }
}

String? rejectReadableUser(
  BuildContext context,
  Ref ref,
  GoRouterState state,
  AuthStateForGuard auth, {
  String? redirectPath,
}) {
  if (_canRead(ref, auth)) {
    return (redirectPath == null)
        ? _defaultHomePath(context, ref, state)
        : redirectPath;
  } else {
    return null;
  }
}

String? rejectNotReadableUser(
  BuildContext context,
  Ref ref,
  GoRouterState state,
  AuthStateForGuard auth, {
  String? redirectPath,
}) {
  if (!_canRead(ref, auth)) {
    return (redirectPath == null)
        ? _defaultHomePath(context, ref, state)
        : redirectPath;
  } else {
    return null;
  }
}

String? rejectNotWritableUser(
  BuildContext context,
  Ref ref,
  GoRouterState state,
  AuthStateForGuard auth, {
  String? redirectPath,
}) {
  if (!_canWrite(ref, auth)) {
    return (redirectPath == null)
        ? _defaultHomePath(context, ref, state)
        : redirectPath;
  } else {
    return null;
  }
}

String? noGuardForDebug(
    BuildContext context, Ref ref, GoRouterState state, AuthStateForGuard auth,
    {String? redirectPath}) {
  logger.d(state);
  return null;
}
