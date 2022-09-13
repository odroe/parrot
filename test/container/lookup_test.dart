import 'package:parrot/src/container/lookup.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  late Lookup lookup;

  setUp(() {
    lookup = Lookup();
  });

  test("should register an instance for a type", () {
    var foo = Foo();

    lookup.register(Foo, foo);

    expect(lookup.instances[Foo], foo);
  });

  test("should get the instance registered for a type", () {
    var foo = Foo();

    lookup.instances[Foo] = foo;

    expect(lookup.get(Foo), foo);
  });

  test("should report whether a type is associated to an instance", () {
    var foo = Foo();

    lookup.instances[Foo] = foo;

    expect(lookup.has(Foo), true);
  });
}

class Foo {}
