// ignore_for_file: constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'logger.dart';

class Config {
  static const _ENV_VERSION = 'ENV_VERSION';
  static const _USE_FB_EMUS = 'USE_FIREBASE_EMULATORS';
  static const _OFFLINE_EDITING_ENABLED = 'OFFLINE_EDITING_ENABLED';
  static const _DEMO_MODE = 'DEMO_MODE';
  static const _SANDBOX_MODE = 'SANDBOX_MODE';
  static const _TEST_MODE = 'TEST_MODE';

  bool _isInitialized = false;
  int _envVersion = 0;
  bool _useFirebaseEmulators = false;
  bool _offlineEditingEnabled = false;
  bool _isDemoMode = false;
  bool _isSandboxMode = false;
  bool _isTestMode = false;

  bool get isInitialized => _isInitialized;

  int get envVersion => _envVersion;

  bool get useFirebaseEmulators => _useFirebaseEmulators;

  bool get offlineEditingEnabled => _offlineEditingEnabled;

  bool get isDemoMode => _isDemoMode;

  bool get isSandboxMode => _isSandboxMode;

  bool get isTestMode => _isTestMode;

  Future<void> configure() async {
    await loadEnvFile();

    _envVersion = getInt(_ENV_VERSION, 0);
    _useFirebaseEmulators = getBool(_USE_FB_EMUS, false);
    _offlineEditingEnabled = getBool(_OFFLINE_EDITING_ENABLED, true);
    _isDemoMode = getBool(_DEMO_MODE, false);
    _isSandboxMode = getBool(_SANDBOX_MODE, false);
    _isTestMode = getBool(_TEST_MODE, false);

    _isInitialized = true;
  }

  Future<void> loadEnvFile() async {
    try {
      await dotenv.load(fileName: "assets/.env");
    } catch (e) {
      logger.e('Failed .env loading: $e');

      logger.i('Load Default Environment.');
      dotenv.testLoad(mergeWith: {
        _ENV_VERSION: '0',
        _USE_FB_EMUS: 'false',
        _OFFLINE_EDITING_ENABLED: 'true',
        _DEMO_MODE: 'false',
        _SANDBOX_MODE: 'false',
        _TEST_MODE: 'false',
      });
    }
    // logger.d('configured.\n${dotenv.env}');
  }

  int getInt(String key, int fallback) {
    int? v = int.tryParse(dotenv.get(_ENV_VERSION, fallback: '$fallback'));
    return v ?? fallback;
  }

  bool getBool(String key, bool fallback) {
    return dotenv.get(key, fallback: '$fallback').toLowerCase() == 'true';
  }

  String toJsonString() {
    String ret = '{\n';
    dotenv.env.forEach((key, value) {
      ret += '  "$key" : "$value",\n';
    });
    ret += '}';
    return ret;
  }
}

final config = Config();
