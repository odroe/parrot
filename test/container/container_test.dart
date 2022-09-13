import 'package:parrot/src/container/container.dart';
import 'package:parrot/src/container/lookup.dart';

import 'package:test/test.dart';

void main() {
  late Lookup lookup;
  late Container container;

  setUp(() {
    lookup = Lookup();
    container = Container(lookup);
  });

  group("register an instance for a type", () {
    test("should register if the type is not associated to instances", () {
      var foo = Foo();

      container.register(Foo, foo);

      expect(lookup.get(Foo), foo);
    });

    test(
        "should use the instance produced by the conflict resolution if the type has been associated to instances",
        () {
      var first = Foo();
      var second = Foo();

      container.register(Foo, first);
      container.register(Foo, second,
          conflictResolution: (older, newer) => newer);

      expect(lookup.get(Foo), second);
    });

    test(
        "should keep the older if the type has been associated to instances and no conflict resolution provided",
        () {
      var first = Foo();
      var second = Foo();

      container.register(Foo, first);
      container.register(Foo, second);

      expect(lookup.get(Foo), first);
    });
  });

  test("should get the instance registered for a type", () {
    var foo = Foo();

    container.register(Foo, foo);

    expect(container.get(Foo), foo);
  });

  test("should report whether a type is associated to instances", () {
    var foo = Foo();

    container.register(Foo, foo);

    expect(container.has(Foo), true);
  });
}

class Foo {}
