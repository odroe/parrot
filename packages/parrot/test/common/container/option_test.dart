import 'package:test/test.dart';

import 'package:parrot/src/common/container/option.dart';

void main() {
  group("Some", () {
    test("should hold a value", () {
      final option = Some(1);

      expect(option.hasValue, true);
      expect(option.value, 1);
    });
  });

  group("None", () {
    test("should not hold value", () {
      final option = None();

      expect(option.hasValue, false);
    });

    test("should throw a unsupported error when accessing value", () {
      final option = None();

      expect(() => option.value, throwsA(isUnsupportedError));
    });
  });
}
