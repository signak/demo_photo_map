import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_share_capp/infra/map/firestore_map_tile_info_repository.dart';
import 'package:photo_share_capp/presentation/service/map_tile_info_service.dart';

import 'app.dart';
import 'core/util/config.dart';
import 'core/util/device_util.dart';
import 'core/util/logger.dart';
import 'core/util/url_strategy/url_strategy.dart';
import 'core/util/version_util.dart';
import 'domain/map/map_tile_info.dart';
import 'firebase_options.dart';
import 'infra/auth/email_authenticator_provider.dart';
import 'infra/auth/firebase_auth_state_provider.dart';
import 'infra/auth/firestore_authorization_repository.dart';
import 'infra/auth/google_authenticator_provider.dart';
import 'infra/firestore_shared_photo_repository.dart';
import 'infra/image_cache/idb_image_cache_manager.dart';
import 'presentation/service/auth/auth_state_service.dart';
import 'presentation/service/auth/authentication_service.dart';
import 'presentation/service/auth/authorization_repository.dart';
import 'presentation/service/shared_photo_repository.dart';
import 'route/demo_router_provider.dart';
import 'route/router_provider.dart';

Future<void> _initializeFirebase(Config config) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (config.useFirebaseEmulators) {
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);

    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);

    await FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);

    logger.i('Firebase Emulators initialized.');
  }

  FirebaseFirestore.instance.settings = Settings(
    sslEnabled: false,
    persistenceEnabled: config.offlineEditingEnabled,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}

Override _getRouterProvider() {
  if (config.isDemoMode) {
    return myRouterProvider
        .overrideWith((ref) => ref.read(myDemoRouterProvider));
  } else {
    return myRouterProvider
        .overrideWith((ref) => ref.read(myReleaseRouterProvider));
  }
}

Future<Override> _initMapTileInfoService() async {
  final repo = FirestoreMapTileInfoRepository();
  final completer = Completer<List<MapTileInfo>>();
  final subsc = repo.watchTiles().listen((event) {
    if (event.isNotEmpty) {
      completer.complete(event);
    }
  });
  late final List<MapTileInfo> tiles;
  try {
    tiles = await completer.future.timeout(const Duration(seconds: 20));
  } catch (e) {
    tiles = [
      FirestoreMapTileInfoRepository.getInfoForFailSafe(),
    ];
  } finally {
    await subsc.cancel();
  }

  final tileLog = tiles
      .map<String>((e) => 'name=${e.name}, uri=${e.tileUri}, by ${e.updatedBy}')
      .join('\n');
  logger.i('[Main] MapTileInfos initialized. \n$tileLog');

  return mapTileInfoServiceProvider.overrideWith(
    (ref) => MapTileInfoService(tiles),
  );
}

Future<Override> _initRepository() async {
  final imageCacheManager = IdbImageCacheManager();
  final imageCacheDbIsOpened = await imageCacheManager.open();
  logger.d(
      'ImageCacheDb as ${imageCacheManager.runtimeType}: isOpened=$imageCacheDbIsOpened');

  final sharedPhotoRepository =
      FirestoreSharedPhotoRepository(imageCacheManager);

  return sharedPhotoRepositoryProvider.overrideWithValue(sharedPhotoRepository);
}

Future<List<Override>> _initAuthProviders() async {
  return [
    authServiceStatusNotifierProvider.overrideWith((ref) {
      return ref.read(firebaseAuthServiceStatusProvider.notifier);
    }),
    authorizationRepositoryProvider
        .overrideWith((ref) => ref.read(firestoreAuthorizationRepository)),
    authenticationServiceProvider.overrideWith(
      (ref) {
        return AuthenticationService(ref,
            googleAuth: ref.read(firebaseGoogleAuthenticatorProvider),
            emailAuth: ref.read(firebaseEmailAuthenticatorProvider));
      },
    ),
    authStateNotifierProvider.overrideWith((ref) {
      return ref.read(firebaseAuthStateNotifierProvider.notifier);
    }),
    authStateStreamProvider.overrideWith((ref) {
      return FirebaseAuthStateStreamBuilder.build(ref);
    }),
  ];
}

Future<List<Override>> _getOverrides() async {
  final List<Override> overrides = [];

  overrides.addAll([
    await initDeviceInfoProvider(),
    await initVersionInfoProvider(shouldOutputVersionsToLog: true),
    ...await _initAuthProviders(),
    await _initRepository(),
    await _initMapTileInfoService(),
    _getRouterProvider(),
  ]);
  return overrides;
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  usePathUrlStrategy();

  await config.configure();
  logger.d("env=${config.toJsonString()}");

  await _initializeFirebase(config);
  final overrides = await _getOverrides();

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const MyApp(),
    ),
  );
}
