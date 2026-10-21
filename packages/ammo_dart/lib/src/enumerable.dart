/// Representation of an enumerated item containing a zero-based index and its corresponding element.
typedef EnumerateData<T> = (int index, T element);

/// Extension on [Iterable] to provide indexed enumeration helpers.
extension Enumerable<T> on Iterable<T> {
  /// Lazily yields records of `(index, element)` for each element in this [Iterable].
  ///
  /// The index is zero-based and increments sequentially with each element.
  ///
  /// Example:
  /// ```dart
  /// for (final (i, item) in ['a', 'b', 'c'].enumerates()) {
  ///   print('$i: $item');
  /// }
  /// ```
  Iterable<EnumerateData<T>> enumerates() sync* {
    var index = 0;
    for (final element in this) {
      yield (index++, element);
    }
  }
}
