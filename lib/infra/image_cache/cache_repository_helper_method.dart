import 'dart:async';

import 'image_cache_manager.dart';

mixin CacheRepositoryHelperMethods on ImageCacheManager {
  int openConnections = 0;
  Completer<bool>? openCompleter;

  bool shouldOpenOnNewConnection() {
    openConnections++;
    openCompleter ??= Completer<bool>();
    return openConnections == 1;
  }

  bool opened() {
    openCompleter!.complete(true);
    return true;
  }

  bool shouldClose({bool force = false}) {
    if (force) {
      openConnections = 0;
    } else {
      openConnections--;
    }

    if (openConnections == 0) {
      openCompleter = null;
    }
    return openConnections == 0;
  }
}
