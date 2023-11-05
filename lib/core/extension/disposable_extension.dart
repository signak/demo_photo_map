// How to easily cancel streams in dart/flutter
// https://medium.com/flutter-community/how-to-easily-cancel-streams-in-dart-flutter-d5a0adc4a311

import 'dart:async';

import 'package:flutter_map/flutter_map.dart';

import '../util/logger.dart';

class DisposableWidget {
  final List<dynamic> _cancelables = [];
  final List<dynamic> _closeables = [];
  final List<dynamic> _disposables = [];

  void disposeManagedObjects() {
    _cancelAll();
    _closeAll();
    _disposeAll();
  }

  void _disposeAll() {
    for (final obj in _disposables) {
      try {
        obj.dispose();
      } on NoSuchMethodError catch (e) {
        logger.e("${obj.runtimeType} doesn't have dispose method.", e);
      } on Exception catch (e) {
        logger.e("failed disposing: ${obj.runtimeType}", e);
      }
    }
    _disposables.clear();
  }

  void _closeAll() {
    for (final obj in _closeables) {
      try {
        obj.close();
      } on NoSuchMethodError catch (e) {
        logger.e("${obj.runtimeType} doesn't have close method.", e);
      } on Exception catch (e) {
        logger.e("failed closing: ${obj.runtimeType}", e);
      }
    }
    _closeables.clear();
  }

  void _cancelAll() {
    for (final obj in _cancelables) {
      try {
        obj.cancel();
      } on NoSuchMethodError catch (e) {
        logger.e("${obj.runtimeType} doesn't have cancel method.", e);
      } on Exception catch (e) {
        logger.e("failed canceling: ${obj.runtimeType}", e);
      }
    }
    _cancelables.clear();
  }

  void addCancelable(dynamic cancelable) {
    if (_cancelables.contains(cancelable)) {
      return;
    }
    _cancelables.add(cancelable);
  }

  void addCloseable(dynamic closeable) {
    if (_closeables.contains(closeable)) {
      return;
    }
    _closeables.add(closeable);
  }

  void addDisposable(dynamic disposable) {
    if (_disposables.contains(disposable)) {
      return;
    }
    _disposables.add(disposable);
  }
}

extension DisposableStreamSubscription on StreamSubscription {
  void disposedBy(DisposableWidget widget) {
    widget.addCancelable(this);
  }
}

extension DisposableStreamController on StreamController {
  void disposedBy(DisposableWidget widget) {
    widget.addCloseable(this);
  }
}

extension DisposableMapController on MapController {
  void disposedBy(DisposableWidget widget) {
    widget.addDisposable(this);
  }
}
