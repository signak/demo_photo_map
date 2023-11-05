import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_share_capp/core/exception/auth/authorization_exception.dart';

import '../../core/extension/datetime_extension.dart';
import '../../core/util/logger.dart';
import '../../domain/auth/authorization_info.dart';
import '../../presentation/service/auth/authorization_repository.dart';
import 'fs_constants.dart';

final firestoreAuthorizationRepository =
    Provider<FirestoreAuthorizationRepository>(
  (ref) {
    ref.onDispose(() {
      ref.state.unsubscribeStream();
    });
    return FirestoreAuthorizationRepository();
  },
);

class FirestoreAuthorizationRepository extends AuthorizationRepository {
  final _db = FirebaseFirestore.instance;

  String? _uid;

  final List<StreamSubscription> _streamListeners = [];

  void unsubscribeStream() {
    for (final listener in _streamListeners) {
      listener.cancel();
    }
    _streamListeners.clear();
    _uid = null;
  }

  Future<void> subscribeStream(
    String uid,
    void Function(AuthorizationInfo) onCompleted, {
    required void Function() onEmpty,
  }) async {
    if (_uid == uid) {
      return;
    }

    unsubscribeStream();

    _uid = uid;

    final authDocRef = _getAuthDocRef(uid);
    final stream = authDocRef.snapshots();

    _streamListeners.add(
      stream.listen((snapshot) {
        // logger.d('authorization listen completed.');
        onCompleted(_convert(_uid!, snapshot.data()));
      }, onDone: () {
        // logger.d('authorization firestore listen done.');
      }, cancelOnError: true),
    );
  }

  AuthorizationInfo _convert(String uid, Map<String, dynamic>? data) {
    if (data == null) {
      return AuthorizationInfo.nodata(uid);
    }

    return AuthorizationInfo(
      uid: uid,
      id: data[FsAuthorizations.id],
      isSystemAdmin: data[FsAuthorizations.systemAdmin],
      isAuthorizationAdmin: data[FsAuthorizations.authorizationAdmin],
      isObservationPointMaintainer:
          data[FsAuthorizations.observationPointMaintainer],
      canRead: data[FsAuthorizations.allowReadObservationData],
      canWrite: data[FsAuthorizations.allowWriteObservationData],
      createdAt: _convertTimestampToDate(data[FsAuthorizations.createdAt]),
      updatedAt: _convertTimestampToDate(data[FsAuthorizations.updatedAt]),
      updatedBy: data[FsAuthorizations.updatedBy],
    );
  }

  Map<String, dynamic> _toFirebase(AuthorizationInfo data,
      {bool forUpdating = false}) {
    return <String, dynamic>{
      FsAuthorizations.id: data.id,
      FsAuthorizations.uid: data.uid,
      FsAuthorizations.allowReadObservationData: data.canRead,
      FsAuthorizations.allowWriteObservationData: data.canWrite,
      FsAuthorizations.authorizationAdmin: data.isAuthorizationAdmin,
      FsAuthorizations.observationPointMaintainer:
          data.isObservationPointMaintainer,
      FsAuthorizations.systemAdmin: data.isSystemAdmin,
      FsAuthorizations.createdAt: data.createdAt!.toTimestamp(),
      FsAuthorizations.updatedAt: (forUpdating)
          ? FieldValue.serverTimestamp()
          : data.updatedAt!.toTimestamp(),
      FsAuthorizations.updatedBy: data.uid,
    };
  }

  @override
  Future<AuthorizationInfo> by(String uid, String email) async {
    final authDocRef = _getAuthDocRef(uid);
    final snapshot = await authDocRef.get();

    if (!snapshot.exists) {
      return await _create(authDocRef, uid, email);
    }

    final id = snapshot.data()![FsAuthorizations.id];
    if (id != email) {
      return await _reset(authDocRef, uid, email, snapshot.data());
    }

    return _convert(uid, snapshot.data());
  }

  Future<AuthorizationInfo> _create(
      DocumentReference<Map<String, dynamic>> docRef,
      String uid,
      String email) async {
    // メールのドメインで初期値を変更する。
    final bool allowReadWrite = email.endsWith('@calmize.net');
    final bool authorizationAdmin = email.endsWith('@calmize.net');

    final initialData = <String, dynamic>{
      FsAuthorizations.uid: uid,
      FsAuthorizations.id: email,
      FsAuthorizations.systemAdmin: false,
      FsAuthorizations.authorizationAdmin: authorizationAdmin,
      FsAuthorizations.observationPointMaintainer: false,
      FsAuthorizations.allowReadObservationData: allowReadWrite,
      FsAuthorizations.allowWriteObservationData: allowReadWrite,
      FsAuthorizations.createdAt: FieldValue.serverTimestamp(),
      FsAuthorizations.updatedAt: FieldValue.serverTimestamp(),
      FsAuthorizations.updatedBy: uid,
    };
    await docRef.set(initialData);
    final snapshot = await docRef.get();
    return _convert(uid, snapshot.data());
  }

  @override
  Future<void> update(
      String updatedBy, String targetUid, Map<String, dynamic> newData) async {
    final authDocRef = _getAuthDocRef(targetUid);

    try {
      await authDocRef.update(<String, dynamic>{
        FsAuthorizations.updatedAt: FieldValue.serverTimestamp(),
        FsAuthorizations.updatedBy: updatedBy,
      }..addAll(newData));
    } on Exception catch (e, st) {
      throw buildException('failed authority updating.', e, stackTrace: st);
    }
  }

  @override
  AuthorizationException buildException(String message, dynamic error,
      {StackTrace? stackTrace}) {
    if (error is AuthorizationException) {
      return error;
    }

    return AuthorizationException.build(
      code: (error is FirebaseException) ? error.code : null,
      plugin: (error is FirebaseException) ? error.plugin : null,
      message: message,
      causeException: error,
      causeStackTrace: stackTrace ??
          ((error is FirebaseException) ? error.stackTrace : null),
    );
  }

  Future<AuthorizationInfo> _reset(
      DocumentReference<Map<String, dynamic>> docRef,
      String uid,
      String email,
      Map<String, dynamic>? data) async {
    await docRef.update({
      FsAuthorizations.id: email,
      FsAuthorizations.systemAdmin: false,
      FsAuthorizations.authorizationAdmin: false,
      FsAuthorizations.observationPointMaintainer: false,
      FsAuthorizations.allowReadObservationData: false,
      FsAuthorizations.allowWriteObservationData: false,
      FsAuthorizations.updatedAt: FieldValue.serverTimestamp(),
      FsAuthorizations.updatedBy: uid,
    });

    final snapshot = await docRef.get();
    return _convert(uid, snapshot.data());
  }

  String _getDocName(String uid) {
    return 'uid_$uid';
  }

  DocumentReference<Map<String, dynamic>> _getAuthDocRef(String uid) {
    final docName = _getDocName(uid);
    return _db.collection(FsAuthorizations.collectionName).doc(docName);
  }

  static DateTime _convertTimestampToDate(dynamic value) {
    if (value != null) {
      try {
        return (value as Timestamp).toDate();
      } on Exception catch (e, st) {
        logger.e("error on timestamp.toDate: '$value'", e, st);
      }
    }

    return DateTime.now();
  }

  @override
  Stream<List<AuthorizationInfo>> getUsersStream(
      {bool excludesAuthorizationAdmins = false, String? excludeUid}) {
    var query = _db
        .collection(FsAuthorizations.collectionName)
        .orderBy(FsAuthorizations.id, descending: false);

    if (excludesAuthorizationAdmins) {
      query = query.where(
        FsAuthorizations.authorizationAdmin,
        isEqualTo: false,
      );
    }

    final queryWithConverter = query.withConverter<AuthorizationInfo>(
      fromFirestore: (snapshot, _) =>
          _convert(snapshot.data()![FsAuthorizations.uid], snapshot.data()!),
      toFirestore: (value, options) => _toFirebase(value, forUpdating: true),
    );

    return queryWithConverter
        .snapshots()
        .transform<List<AuthorizationInfo>>(StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            final ret = <AuthorizationInfo>[];
            for (final snapshot in data.docs) {
              if (snapshot.data().uid == excludeUid) {
                continue;
              }
              ret.add(snapshot.data());
            }
            sink.add(ret);
          },
          handleError: (error, stackTrace, sink) {
            const String message = '権限情報の取得時に予期しないエラーが発生しました。';
            _handleError(message, error, stackTrace, sink);
          },
        ));
  }

  void _handleError(
      String message, Object error, StackTrace stackTrace, EventSink sink) {
    late final Exception? causeException;
    late final String? code;
    late final String? plugin;
    if (error is FirebaseException) {
      code = error.code;
      plugin = error.plugin;
      causeException = error;
    } else {
      code = null;
      plugin = null;
      causeException = (error is Exception)
          ? error
          : Exception("the error object didn't implement of Exception class: "
              "${error.runtimeType} - $error");
    }

    final ex = AuthorizationException.build(
      message: message,
      code: code,
      plugin: plugin,
      causeException: causeException,
      causeStackTrace: stackTrace,
    );
    sink.addError(ex);
  }
}
