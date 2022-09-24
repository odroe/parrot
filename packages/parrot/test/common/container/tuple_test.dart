import 'package:test/test.dart';

import 'package:parrot/src/common/container/tuple.dart';

void main() {
  group("Tuple2", () {
    test("should assign value in order", () {
      const tuple = Tuple2(1, 2);

      expect(tuple.first, 1);
      expect(tuple.second, 2);
    });

    group("flatMap()", () {
      test("should run and return the result from [mapper]", () {
        const tuple = Tuple2(1, 2);

        final result =
            tuple.flatMap((first, second) => Tuple2(first + 1, second + 1));

        expect(result.first, 2);
        expect(result.second, 3);
      });
    });

    group("cast()", () {
      test("should casting the type on each value", () {
        const foo = Foo();
        const bar = Bar();
        const tuple = Tuple2(foo, bar);

        final result = tuple.cast<Base, Base>();

        expect(result.first, foo);
        expect(result.second, bar);
      });

      test(
        "should throw a cast error if cannot casting the type on each value",
        () {
          const foo = Foo();
          const bar = Bar();
          const tuple = Tuple2(foo, bar);

          expect(() => tuple.cast<NotAFoo, NotABar>(), throwsA(isCastError));
        },
      );
    });
  });

  group("Tuple3", () {
    test("should assign value in order", () {
      const tuple = Tuple3(1, 2, 3);

      expect(tuple.first, 1);
      expect(tuple.second, 2);
      expect(tuple.third, 3);
    });

    group("flatMap()", () {
      test("should run and return the result from [mapper]", () {
        const tuple = Tuple3(1, 2, 3);

        final result = tuple.flatMap(
            (first, second, third) => Tuple3(first + 1, second + 1, third + 1));

        expect(result.first, 2);
        expect(result.second, 3);
        expect(result.third, 4);
      });
    });

    group("cast()", () {
      test("should casting the type on each value", () {
        const foo = Foo();
        const bar = Bar();
        const baz = Baz();
        const tuple = Tuple3(foo, bar, baz);

        final result = tuple.cast<Base, Base, Base>();

        expect(result.first, foo);
        expect(result.second, bar);
        expect(result.third, baz);
      });

      test(
        "should throw a cast error if cannot casting the type on each value",
        () {
          const foo = Foo();
          const bar = Bar();
          const baz = Baz();
          const tuple = Tuple3(foo, bar, baz);

          expect(() => tuple.cast<NotAFoo, NotABar, NotABaz>(),
              throwsA(isCastError));
        },
      );
    });
  });
}

abstract class Base {
  const Base();
}

class Foo extends Base {
  const Foo();
}

class Bar extends Base {
  const Bar();
}

class Baz extends Base {
  const Baz();
}

class NotAFoo {
  const NotAFoo();
}

class NotABar {
  const NotABar();
}

class NotABaz {
  const NotABaz();
}
