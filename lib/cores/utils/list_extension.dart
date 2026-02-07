extension ListExtension<E> on List<E>? {
  bool get isNotNullOrEmpty {
    List list = this ?? [];
    return list.isNotEmpty;
  }

  bool get isNullOrEmpty {
    List list = this ?? [];
    return list.isEmpty;
  }

  E firstOr(E value) => this?.firstOrNull ?? value;

  List<R> mapWithIndex<R>(R Function(E, int i) callback) {
    if (this == null) {
      return [];
    }

    List<R> result = [];
    for (int i = 0; i < (this ?? []).length; i++) {
      R item = callback((this ?? [])[i], i);
      result.add(item);
    }
    return result;
  }

  void assignAll(List<E> newItems) {
    this?.clear();
    this?.addAll(newItems);
  }

  void addAllIfNotExists(List<E> newItems, dynamic Function(E) keySelector) {
    final existingKeys = this?.map(keySelector).toSet();

    for (final item in newItems) {
      if (existingKeys != null && !existingKeys.contains(keySelector(item))) {
        this?.add(item);
        existingKeys.add(keySelector(item)); // Update keys as we go
      }
    }
  }
}

class ListHelper {
  static bool hasDuplicateBy<T, K>(
    List<T> existing,
    List<T> incoming,
    K Function(T item) keySelector,
  ) {
    final existingKeys = existing.map(keySelector).toSet();
    return incoming.any((item) => existingKeys.contains(keySelector(item)));
  }

  static List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }
}
