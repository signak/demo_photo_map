extension IndexedMap<T, E> on List<T> {
  List<R> indexedMap<R>(R Function(int index, T item) function) {
    final list = <R>[];
    asMap().forEach((index, element) {
      list.add(function(index, element));
    });
    return list;
  }
}
