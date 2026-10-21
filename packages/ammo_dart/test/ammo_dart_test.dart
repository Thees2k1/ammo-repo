import 'package:ammo_dart/ammo_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AmmoStringX', () {
    test('isBlank returns true for whitespace or empty string', () {
      expect(''.isBlank, isTrue);
      expect('   '.isBlank, isTrue);
      expect('hello'.isBlank, isFalse);
    });

    test('capitalize capitalizes first character', () {
      expect('ammo'.capitalize(), equals('Ammo'));
      expect(''.capitalize(), equals(''));
    });
  });

  group('Enumerable<T>.enumerates()', () {
    test('pairs elements with zero-based indexes', () {
      expect(['A', 'B', 'C'].enumerates().toList(), [
        (0, 'A'),
        (1, 'B'),
        (2, 'C'),
      ]);
    });

    test('returns an empty iterable for empty input', () {
      expect(<String>[].enumerates().toList(), isEmpty);
    });

    test('preserves element types', () {
      final result = <int>[10, 20].enumerates();
      expect(result.toList(), [(0, 10), (1, 20)]);
    });

    test('supports single-pass lazy iteration', () {
      var visits = 0;

      final source = Iterable<int>.generate(3, (i) {
        visits++;
        return i * 10;
      });

      final result = source.enumerates();

      expect(visits, 0); // Nothing evaluated yet.

      expect(result.take(2).toList(), [(0, 0), (1, 10)]);
      expect(visits, 2); // Only two elements evaluated.
    });

    test('works with Sets and maintains sequential zero-based indexes', () {
      final set = {'x', 'y', 'z'};
      expect(set.enumerates().toList(), [(0, 'x'), (1, 'y'), (2, 'z')]);
    });

    test('works with bounded consumption on large/infinite iterables', () {
      final numbers = Iterable<int>.generate(1000000, (i) => i);
      final firstThree = numbers.enumerates().take(3).toList();
      expect(firstThree, [(0, 0), (1, 1), (2, 2)]);
    });
  });
}
