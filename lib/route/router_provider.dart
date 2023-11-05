import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_share_capp/core/util/logger.dart';

import '../core/screen/photo_view_screen.dart';
import '../presentation/page/authorization_control_page.dart';
import '../presentation/page/item_edit_dialog.dart';
import '../presentation/page/login_page.dart';
import '../presentation/page/photo_share_app_home_page.dart';
import '../presentation/service/auth/auth_state_service.dart';
import 'guard.dart';
import 'routes.dart';

// TODO [低] TypedGoRoute使うようにする
final Provider<GoRouter> myRouterProvider = Provider<GoRouter>(
  (ref) => throw UnimplementedError('should override myRouterProvider.'),
);

final myReleaseRouterProvider = Provider<GoRouter>(
  (ref) {
    final authStateNotifier = ref.read(authStateNotifierProvider.notifier);

    return GoRouter(
      refreshListenable: authStateNotifier.valueListener,
      initialLocation: ReleaseRoutes.home.path,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          name: ReleaseRoutes.signIn.name,
          path: ReleaseRoutes.signIn.path,
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const LoginPage(),
            );
          },
          redirect: (context, state) => combineGuard(context, state, ref, [
            rejectReadableUser,
          ], redirectPaths: [
            ReleaseRoutes.home.path,
          ]),
        ),
        GoRoute(
          name: ReleaseRoutes.home.name,
          path: ReleaseRoutes.home.path,
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const PhotoShareAppHomePage(),
            );
          },
          redirect: (context, state) => combineGuard(context, state, ref, [
            rejectNotReadableUser,
          ], redirectPaths: [
            ReleaseRoutes.signIn.path,
          ]),
          routes: [
            GoRoute(
              name: ReleaseRoutes.logView.name,
              path: ReleaseRoutes.logView.path,
              pageBuilder: (context, state) {
                return MaterialPage(
                  key: state.pageKey,
                  child: const LogViewerPage(),
                );
              },
              redirect: (context, state) => combineGuard(context, state, ref, [
                rejectNotAdministrator,
              ], redirectPaths: [
                ReleaseRoutes.home.path,
              ]),
            ),
            GoRoute(
              name: ReleaseRoutes.authorization.name,
              path: ReleaseRoutes.authorization.path,
              pageBuilder: (context, state) {
                return MaterialPage(
                  key: state.pageKey,
                  child: const AuthorizationControlPage(),
                );
              },
              redirect: (context, state) => combineGuard(context, state, ref, [
                rejectNotAuthorizationAdmin,
              ], redirectPaths: [
                ReleaseRoutes.signIn.path,
              ]),
            ),
            GoRoute(
              path: ReleaseRoutes.edit.path,
              name: ReleaseRoutes.edit.name,
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: ItemEditDialog(state.params['id']!),
              ),
              redirect: (context, state) => combineGuard(context, state, ref, [
                rejectNotReadableUser,
              ], redirectPaths: [
                ReleaseRoutes.signIn.path,
              ]),
              routes: [
                GoRoute(
                  path: ReleaseRoutes.photoView.path,
                  name: ReleaseRoutes.photoView.name,
                  pageBuilder: (context, state) {
                    final recordId = int.parse(state.params['id']!);
                    final imageIndex = int.parse(state.params['imageIndex']!);
                    final extra = state.extra! as Map<String, dynamic>;
                    final fileName = extra['fileName'] as String;
                    final image = extra['memoryImage'] as MemoryImage;
                    return MaterialPage(
                      key: state.pageKey,
                      fullscreenDialog: true,
                      child: PhotoViewScreen(
                          recordId: recordId,
                          imageIndex: imageIndex,
                          imageName: fileName,
                          memoryImage: image),
                    );
                  },
                  redirect: (context, state) =>
                      combineGuard(context, state, ref, [
                    rejectNotReadableUser,
                  ], redirectPaths: [
                    ReleaseRoutes.signIn.path,
                  ]),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
);

// ignore: unused_element
CustomTransitionPage<void> _buildPageWithAnimation(
    {LocalKey? key, bool? fullscreenDialog, required Widget child}) {
  return CustomTransitionPage(
    key: key,
    fullscreenDialog: fullscreenDialog ?? false,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeIn)),
        ),
      );
    },
  );
}
