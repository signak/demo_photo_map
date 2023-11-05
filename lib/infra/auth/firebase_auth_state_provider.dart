import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/util/logger.dart';
import '../../domain/auth/auth_state.dart';
import '../../domain/auth/authorization_info.dart';
import '../../presentation/service/auth/auth_state_notifier.dart';
import '../../presentation/service/auth/auth_state_service.dart';
import '../../presentation/service/auth/authorization_repository.dart';
import 'firebase_auth_state.dart';
import 'firebase_auth_state_util.dart';
import 'firestore_authorization_repository.dart';

final firebaseAuthServiceStatusProvider =
    StateNotifierProvider<AuthServiceStatusNotifier, AuthServiceStatus>(
  (ref) => AuthServiceStatusNotifier(
      'firebase_auth', AuthServiceStatus.initializing),
);

/// ログイン状態の監視を行いログイン状態の変化を通知するNotifierをProviderを通じて提供する。
/// 使用する際にはProviderScopeでStateNotifierProvider<AuthStateNotifier, AuthState?>をoverrideし、AuthStateNotifierとして使用する。
final firebaseAuthStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState?>(
  (ref) {
    final authorizationRepository = ref.read(firestoreAuthorizationRepository);
    ref.onDispose(() {
      authorizationRepository.unsubscribeStream();
    });

    return FirebaseAuthStateNotifier(
        authorizationRepository, FirebaseAuthState.initial());
  },
);

/// ログイン状態の変化を通知する。
class FirebaseAuthStateNotifier extends AuthStateNotifier {
  FirebaseAuthStateNotifier(
      FirestoreAuthorizationRepository authorizationRepository,
      AuthState? initialState)
      : _authorizationRepository = authorizationRepository,
        super(initialState);

  final FirestoreAuthorizationRepository _authorizationRepository;

  @override
  void change(AuthState? authState) {
    final uid = authState?.uid;
    if (uid == null) {
      _authorizationRepository.unsubscribeStream();
    } else {
      _authorizationRepository.subscribeStream(
        uid,
        (info) {
          _changeAuthorization(info);
        },
        onEmpty: () => {},
      );
    }

    state = authState;
    super.change(authState);
  }

  void _changeAuthorization(AuthorizationInfo info) {
    final newState =
        (state as FirebaseAuthState).copyWith(authorizationInfo: info);
    state = newState;
    super.change(newState);
  }

  @override
  Future<void> reload() async {
    if (state != null && state is FirebaseAuthState) {
      await (state as FirebaseAuthState).rawUser?.reload();
    }
  }
}

class FirebaseAuthStateStreamBuilder {
  const FirebaseAuthStateStreamBuilder._();

  /// ログイン状態をStreamで提供するとともに、
  /// 状態に変化があった場合はauthStateNotifierProviderを通じて通知を行う。
  /// なお、提供・通知する状態がログイン済みだった場合は、
  /// 認可情報の取得を行ってStateオブジェクトに設定してから提供・通知を行う。
  static Stream<AuthState?> build(StreamProviderRef<AuthState?> ref) {
    final notifier = ref.read(firebaseAuthStateNotifierProvider.notifier);
    final serviceStatusNotifier =
        ref.read(firebaseAuthServiceStatusProvider.notifier);
    final authorizationRepository = ref.read(authorizationRepositoryProvider);

    bool isStateInitialized(AsyncValue<AuthState?>? v) {
      return (v == null || v.value == null) ? false : v.value!.isInitialized;
    }

    ref.listenSelf(
      (prev, next) {
        // logger.d('[FbAuthStateProvider] listenSelf: '
        //     'prev=${prev?.value?.uid}, next=${next.value?.uid}');
        if (next.value != null && !next.value!.isInitialized) {
          // logger.d('[FbAuthStateProvider] rejects status change notification, '
          //     'because it has not probably finished initializing yet.');
          return;
        }

        if (serviceStatusNotifier.isNotReady()) {
          final bool prevIsInitialized = isStateInitialized(prev);
          final bool nextIsInitialized = isStateInitialized(next);

          if (!prevIsInitialized && nextIsInitialized) {
            logger
                .d('[FbAuthStateProvider] listenSelf: auth service is ready.');
            serviceStatusNotifier.completeInitialization();
          } else {
            // logger.d(
            //     '[FbAuthStateProvider] listenSelf: auth service is initializing.');
          }
        }

        // logger.d(
        //     '[FbAuthStateProvider] emailVerified: prev=${prev?.value?.emailVerified}, next=${next.value?.emailVerified}');

        if (!FirebaseAuthStateUtil.valueEquals(prev?.value, next.value)) {
          notifier.change(next.value);
        }
      },
    );

    return FirebaseAuth.instance.authStateChanges().asyncMap<AuthState>(
      (user) async {
        final state = FirebaseAuthStateUtil.buildFrom(user);
        // logger.d(
        //     '[FbAuthStateProvider] fb.authStateChanges: rowUser.uid:${user?.uid}, '
        //     'state: {uid:${state.uid}, singedIn:${state.isSignedIn}, '
        //     'provider:${state.provider}, emailVerified:${state.emailVerified}, '
        //     'canRead:${state.canRead},}');
        if (user?.uid == null) {
          // サインアウト状態の場合は認可情報を取得しない
          return state;
        }
        final uid = state.uid!;
        final email = state.email!;
        final authInfo = await authorizationRepository.by(uid, email);
        final mergedState = state.copyWith(authorizationInfo: authInfo);
        return mergedState;
      },
    );
  }
}
