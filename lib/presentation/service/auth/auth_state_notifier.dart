import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/auth/auth_state.dart';

abstract class AuthStateNotifier extends StateNotifier<AuthState?> {
  AuthStateNotifier(AuthState? initialValue)
      : _valueListener = _AuthStateValueNotifier(initialValue),
        super(initialValue);

  final ValueNotifier<AuthState?> _valueListener;

  void change(AuthState? authState) {
    // logger.d('authState changed: ${authState?.uid}');
    _valueListener.value = authState;
  }

  Listenable get valueListener {
    return _valueListener;
  }

  Future<void> reload();
}

class _AuthStateValueNotifier extends ValueNotifier<AuthState?> {
  _AuthStateValueNotifier(super.value);
}
