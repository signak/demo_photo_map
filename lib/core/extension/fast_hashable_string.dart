extension FastHashableString on String {
  /// Dart Stringsの為に最適化されたFNV-1a 64bitハッシュアルゴリズム
  int fastHash() {
    return hashCode;
    // var hash = 0xcbf29ce484222325;

    // var i = 0;
    // while (i < length) {
    //   final codeUnit = codeUnitAt(i++);
    //   hash ^= codeUnit >> 8;
    //   hash *= 0x100000001b3;
    //   hash ^= codeUnit & 0xFF;
    //   hash *= 0x100000001b3;
    // }

    // return hash;
  }
}
