import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:photo_share_capp/core/extension/datetime_extension.dart';
import 'package:universal_platform/universal_platform.dart';

/// Usage:
/// import 'package:wl_obs_capp/core/util/logger.dart';
/// logger.d('some log message.');
final logger = Logger(
  level: (kDebugMode) ? Level.debug : Level.info,
  filter: _SimpleLogFilter(),
  output: (UniversalPlatform.isWeb) ? _LocalstorageLogOutput() : null,
  printer: (kDebugMode)
      ? PrettyPrinter(
          methodCount: 1, // 表示されるコールスタックの数
          errorMethodCount: 5, // 表示されるスタックトレースのコールスタックの数
          // lineLength: 120, // 出力するログ1行の幅
          // colors: true, // メッセージに色をつけるかどうか
          // printEmojis: true, // 絵文字を出力するかどうか
          printTime: true, // タイムスタンプを出力するかどうか
          excludeBox: {
            Level.debug: true,
          },
        )
      : SimplePrinter(printTime: true),
);

class _SimpleLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= level!.index;
  }
}

class _LocalstorageLogOutput extends LogOutput {
  _LocalstorageLogOutput();

  final _initCompleter = Completer<bool>();
  bool _ready = false;
  IdbLogManager? _storage;
  StreamController<OutputEvent>? _outputStream;

  bool get isReady => _ready;
  bool get isInitialized => _initCompleter.isCompleted;
  final LogOutput? _console = (kDebugMode) ? ConsoleOutput() : null;

  @override
  void init() {
    if (isReady && _storage != null) {
      return;
    }

    _storage = IdbLogManager()
      ..open().then((ret) {
        if (ret) {
          _outputStream = StreamController<OutputEvent>(sync: true)
            ..stream.listen((event) => _saveEventToStorage(event));
          _ready = true;

          // const message = 'storage opened and stream initialized.';
          // final event = OutputEvent(LogEvent(Level.info, message), [message]);
          // output(event);
        }
        _initCompleter.complete(ret);
      });

    _console?.init();
  }

  final _consoleColorCodeRegExp =
      RegExp('\u001b\\[[^m]+m', caseSensitive: false);

  String _removeConsoleColorCode(String message) {
    return message.replaceAll(_consoleColorCodeRegExp, '');
  }

  Future<void> _saveEventToStorage(OutputEvent event) async {
    final now = DateTime.now();
    final logText = event.lines
        .map((message) => _removeConsoleColorCode(message))
        .join('\n');
    await _storage?.insert(now, logText);
  }

  @override
  void destroy() {
    _console?.destroy();
    _outputStream?.close();
    // _storage?.close();
  }

  @override
  void output(OutputEvent event) {
    _console?.output(event);
    if (isReady) {
      _output(event);
    } else {
      _reserve(event);
    }
  }

  void _reserve(OutputEvent event) {
    _initCompleter.future.then((ret) {
      if (ret) {
        _output(event);
      }
    });
  }

  void _output(OutputEvent event) {
    _outputStream?.sink.add(event);
  }
}

class _IdbLogs {
  static const String databaseName = 'web_app_logs.db';
  static const int databaseVersion = 1;

  static const String storeName = 'logs'; // TableName
  static const String primaryKey = id;

  static const String idxDaysEpochLoggedAt = 'IDX_$daysEpochLoggedAt';

  static const String id = 'id';
  static const String loggedAt = 'logged_at';
  static const String message = 'message';
  static const String daysEpochLoggedAt = 'days_epoch_logged_at';
}

class IdbLogEntry {
  IdbLogEntry(this.id, this.loggedAt, this.message, this.daysEpochLoggedAt);

  factory IdbLogEntry.fromMap(Map data) {
    return IdbLogEntry(
        data[_IdbLogs.id] as int,
        data[_IdbLogs.loggedAt] as DateTime,
        data[_IdbLogs.message] as String,
        data[_IdbLogs.daysEpochLoggedAt] as int);
  }

  final int id;
  final DateTime loggedAt;
  final String message;
  final int daysEpochLoggedAt;
}

abstract class _LogManager {}

mixin _CacheRepositoryHelperMethods on _LogManager {
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

class IdbLogManager extends _LogManager with _CacheRepositoryHelperMethods {
  factory IdbLogManager() {
    return _instance;
  }

  IdbLogManager._() {
    //
  }

  static final IdbLogManager _instance = IdbLogManager._();

  static const int _defaultExpiredDays = 15;
  static const String _databaseFactoryName = idbFactoryNameBrowser;
  Database? _db;

  Future<bool> open({bool skipDeleteExpired = false}) async {
    if (!shouldOpenOnNewConnection()) {
      return openCompleter!.future;
    }

    final idbFactory = getIdbFactory(_databaseFactoryName);
    if (idbFactory == null) {
      throw DatabaseError(
          "No idbFactory of type '$_databaseFactoryName' supported on this platform.");
    }
    _db = await idbFactory.open(
      _IdbLogs.databaseName,
      version: _IdbLogs.databaseVersion,
      onUpgradeNeeded: (event) {
        Database db = (event.target as OpenDBRequest).result;

        if (!db.objectStoreNames.contains(_IdbLogs.storeName)) {
          final store = event.database.createObjectStore(
            _IdbLogs.storeName,
            keyPath: _IdbLogs.primaryKey,
            autoIncrement: false,
          );
          store.createIndex(
              _IdbLogs.idxDaysEpochLoggedAt, _IdbLogs.daysEpochLoggedAt);
        }
      },
    );

    if (!skipDeleteExpired) {
      await _deleteExpiredLogs();
    }

    return opened();
  }

  Future<int> _deleteExpiredLogs({int expireDays = _defaultExpiredDays}) async {
    final borderDate = DateTime.now().add(Duration(days: -expireDays));
    final borderDaysEpoch = borderDate.daysEpoch;
    final txn = _db!.transaction(_IdbLogs.storeName, idbModeReadWrite);
    final store = txn
        .objectStore(_IdbLogs.storeName)
        .index(_IdbLogs.idxDaysEpochLoggedAt);

    int deleteCount = 0;

    try {
      // upperBound: レコードを昇順に並べた時に、指定した条件のレコードよりも上に配置されるレコードを対象とする。
      // lowerBound: レコードを昇順に並べた時に、指定した条件のレコードよりも下に配置されるレコードを対象とする。
      final cursor =
          store.openCursor(range: KeyRange.upperBound(borderDaysEpoch));
      final completer = Completer<Object?>();

      cursor.listen(
        (cv) {
          try {
            // final data = cv.value as Map;
            // final id = data[IdbLogs.id];
            // final loggedAt = data[IdbLogs.loggedAt] as DateTime;
            // final epoch = data[IdbLogs.daysEpochLoggedAt] as int;

            cv.delete();
            deleteCount++;
            cv.next();
          } catch (e) {
            rethrow;
          }
        },
        onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(e);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      final ret = await completer.future;
      if (ret == null) {
        await txn.completed;
      } else {
        txn.abort();
      }
    } catch (err) {
      // logger.e('error on openCursor', err, st);
    }

    return deleteCount;
  }

  Future<bool> close({bool force = false}) async {
    if (!shouldClose(force: force)) return false;
    _db!.close();
    return true;
  }

  Future<bool> flush() async {
    bool ret = false;
    if (await close(force: true)) {
      ret = await open(skipDeleteExpired: true);
    }
    return ret;
  }

  Future<int> getRecordCount() async {
    final txn = _db!.transaction(_IdbLogs.storeName, idbModeReadOnly);
    final store = txn.objectStore(_IdbLogs.storeName);
    final ret = await store.count();
    return ret;
  }

  Future<int> insert(DateTime loggedAt, String message) async {
    try {
      final txn = _db!.transaction(_IdbLogs.storeName, idbModeReadWrite);
      final store = txn.objectStore(_IdbLogs.storeName);
      late final int nextId;
      try {
        if ((await store.count()) == 0) {
          nextId = 1;
        } else {
          nextId = (((await store.openCursor(direction: idbDirectionPrev).first)
                  .value as Map)[_IdbLogs.id] as int) +
              1;
        }
      } catch (e) {
        nextId = 1;
      }

      final data = <dynamic, dynamic>{
        _IdbLogs.id: nextId,
        _IdbLogs.loggedAt: loggedAt,
        _IdbLogs.message: message,
        _IdbLogs.daysEpochLoggedAt: loggedAt.daysEpoch,
      };

      final ret = await store.add(data);
      await txn.completed;
      return (ret is int) ? ret : (ret as Map)[_IdbLogs.id] as int;
    } catch (e) {
      // nop
    }
    return 0;
  }

  Future<List<IdbLogEntry>?> getAll() async {
    final txn = _db!.transaction(_IdbLogs.storeName, idbModeReadOnly);
    final store = txn.objectStore(_IdbLogs.storeName);

    List<IdbLogEntry> ret = [];
    try {
      final objects = await store.getAll();
      if (objects.isEmpty) {
        // logger.d(
        //     'IdbImageCacheManager#get: obj was not found in "${store.name}": $name');
      } else if (objects.first is! Map) {
        // logger.d(
        //     'IdbImageCacheManager#get: obj found but type is not Map in "${store.name}": $name');
      } else {
        for (final obj in objects) {
          ret.add(IdbLogEntry.fromMap(obj as Map));
        }

        // logger
        //     .d('IdbImageCacheManager#get: obj found in "${store.name}": $name\ndata=$data');
      }
      // }
      await txn.completed;
    } catch (err) {
      // logger.e('IdbImageCacheManager#get: error raised', err, st);
    }
    if (ret.isEmpty) {
      return null;
    }
    return ret;
  }

  Future<bool> clear() async {
    final txn = _db!.transaction(_IdbLogs.storeName, idbModeReadWrite);
    try {
      await txn.objectStore(_IdbLogs.storeName).clear();
      return true;
    } catch (e) {
      // logger.e('failed image cache clearing.', e, st);
    }
    return false;
  }
}

class LogViewerPage extends StatelessWidget {
  const LogViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Viewer')),
      body: Container(
        margin: const EdgeInsets.all(16),
        alignment: Alignment.topCenter,
        child: const LogViewerWidget(),
      ),
    );
  }
}

class LogViewerWidget extends StatelessWidget {
  const LogViewerWidget({super.key, this.dateTimeFormat = 'HH:mm:ss.SSS'});

  final String dateTimeFormat;

  Future<void> _downloadLogs(List<IdbLogEntry> logs) async {
    final f = DateFormat('yyyyMMdd_HHmm');
    final date = f.format(DateTime.now());
    final fileName = '$date.log';

    final String? path = await getSavePath(suggestedName: fileName);
    if (path == null) {
      // Operation was canceled by the user.
      return;
    }

    final Uint8List fileData = Uint8List.fromList(logs.join('\n').codeUnits);
    const String mimeType = 'text/plain';
    final XFile textFile =
        XFile.fromData(fileData, mimeType: mimeType, name: fileName);
    await textFile.saveTo(path);
  }

  @override
  Widget build(BuildContext context) {
    Future<List<IdbLogEntry>> getLogs() async {
      IdbLogManager? logManager;
      try {
        logManager = IdbLogManager();
        await logManager.open();

        final logs = await logManager.getAll();
        return (logs == null) ? [] : logs;
      } finally {
        await logManager?.close();
      }
    }

    Future<void> clearLogs() async {
      IdbLogManager? logManager;
      try {
        logManager = IdbLogManager();
        await logManager.open();
        await logManager.clear();
      } finally {
        await logManager?.close();
      }
    }

    final dateTimeFormatter = DateFormat(dateTimeFormat);

    return FutureBuilder(
      initialData: const <IdbLogEntry>[],
      future: getLogs(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final logs = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                            const Size.fromWidth(180))),
                    onPressed: () async {
                      await clearLogs();
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear Logs'),
                  ),
                  const Gap(8),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                            const Size.fromWidth(180))),
                    onPressed: () async {
                      await _downloadLogs(logs);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Logs'),
                  ),
                ],
              ),
              const Gap(8),
              Flexible(
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final entity = logs[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      color: (index % 2 == 0)
                          ? Colors.blueGrey.withAlpha(64)
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(dateTimeFormatter.format(entity.loggedAt)),
                          const Gap(12),
                          Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(entity.message)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('no data'));
        }
      },
    );
  }
}
