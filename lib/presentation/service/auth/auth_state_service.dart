import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/util/logger.dart';
import '../../../domain/auth/auth_state.dart';
import 'auth_state_notifier.dart';

enum AuthServiceStatus {
  initializing('initializing'),
  ready('ready'),
  ;

  const AuthServiceStatus(this.value);
  final String value;
  String get path => '/${value.toLowerCase()}';
}

class AuthServiceStatusNotifier extends StateNotifier<AuthServiceStatus> {
  AuthServiceStatusNotifier(this.providerName, super.state);

  final String providerName;

  void completeInitialization() {
    logger.d('[AuthServiceStateNotifier] completeInitialization');
    try {
      FlutterNativeSplash.remove();
    } catch (e) {
      logger.e(
          '[AuthServiceStateNotifier] error on called FlutterNativeSplash.remove',
          e);
    }
    state = AuthServiceStatus.ready;
  }

  bool isReady() {
    return state == AuthServiceStatus.ready;
  }

  bool isNotReady() {
    return state != AuthServiceStatus.ready;
  }
}

final authServiceStatusNotifierProvider =
    StateProvider<AuthServiceStatusNotifier>(
  (ref) => throw UnimplementedError(
      'should override authServiceStatusNotifierProvider'),
);

final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState?>(
  (ref) => throw UnimplementedError('should override authStateNotifier'),
);

final authStateStreamProvider = StreamProvider<AuthState?>(
  (ref) => throw UnimplementedError('should override authStateStreamProvider'),
);
