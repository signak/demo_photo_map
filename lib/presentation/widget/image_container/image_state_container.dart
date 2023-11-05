import 'package:flutter/foundation.dart';
import 'package:quiver/collection.dart';

import 'image_state.dart';

/// 複数の画像情報を保持するコンテナのインターフェース
abstract class ImageStateContainer {
  /// [name]のStateを保持している場合はtrueを返す
  bool containsKey(String name);

  /// [newStates]で渡されたStateで更新したContainerを返す。<br>
  /// ただし、既に保持しているStateを更新することしかできないので、<br>
  /// 新規(containsKey(newStates\[n\].name) == false)のStateを渡した場合は例外が発生する。
  ImageStateContainer copyWithImageStates(List<ImageState> newStates);

  /// 保有しているStateを解放する
  void dispose();

  /// 保有しているすべてのStateが読み込み済みの場合はtrue。
  /// ひとつ以上のStateが未読み込み（取得失敗、キャンセルも含む）の場合はfalse。
  bool get isLoaded;

  /// 保有しているStateの数を返す。
  int get length;

  /// indexを取得する。
  int indexOf(String name);

  /// Stateを取得する。
  ImageState? of(String name);

  /// stateリストのコピーを取得する
  List<ImageState> get states;
}

/// 複数の画像情報を保持するimmutableなコンテナ
@immutable
class ImageStateContainerImpl implements ImageStateContainer {
  const ImageStateContainerImpl(
    List<String> names,
    List<ImageState> states,
  )   : _names = names,
        _states = states;

  factory ImageStateContainerImpl.create(int recordId, List<String> names) {
    final initialStates = <ImageState>[];
    for (final name in names) {
      initialStates.add(ImageState.createNewState(recordId, name));
    }
    return ImageStateContainerImpl([...names], initialStates);
  }

  factory ImageStateContainerImpl.empty() {
    return const ImageStateContainerImpl([], []);
  }

  final List<String> _names;
  final List<ImageState> _states;

  @override
  int get length => _names.length;

  @override
  bool get isLoaded {
    for (final state in _states) {
      if (!state.isLoaded) {
        return false;
      }
    }
    return true;
  }

  @override
  List<ImageState> get states => [..._states];

  @override
  bool containsKey(String name) {
    return _names.contains(name);
  }

  @override
  int indexOf(String name) {
    return _names.indexOf(name);
  }

  void updateState(String name, ImageState newState) {
    _states[indexOf(name)] = newState;
  }

  @override
  ImageState? of(String name) {
    if (!containsKey(name)) {
      return null;
    }

    final index = indexOf(name);
    return _states[index];
  }

  @override
  void dispose() {
    _names.clear();
    _states.clear();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! ImageStateContainerImpl || runtimeType != other.runtimeType) {
      return false;
    }
    return setsEqual(_names.toSet(), other._names.toSet());
  }

  @override
  int get hashCode {
    final keys = [..._names];
    keys.sort((a, b) => a.compareTo(b));
    return keys.join('').hashCode;
  }

  @override
  ImageStateContainer copyWithImageStates(List<ImageState> newStates) {
    final updatedStates = [..._states];
    for (final newState in updatedStates) {
      final index = indexOf(newState.name);
      updatedStates[index] = newState;
    }
    return ImageStateContainerImpl(_names, updatedStates);
  }

  // void debugPrint() {
  //   if (!kDebugMode) {
  //     return;
  //   }

  //   final buf = <String>[];
  //   final d = buf.add;
  //   d('Container.States: [');
  //   for (final s in _states) {
  //     d('\t${s.toString()}');
  //   }
  //   d(']');
  //   logger.d(buf.join('\n'));
  // }
}
