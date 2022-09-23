import 'package:parrot/src/container/v1/internal/container.dart';
import 'package:test/test.dart';

void main() {
  late ParrotContainer container;

  setUp(() {
    container = ParrotContainer();
  });

  test("should returns the parent container", () {
    final child = ParrotContainer(parent: container);

    expect(child.parent, container);
  });

  test("should returns the root container", () {
    final depthOnSecond = ParrotContainer(parent: container);
    final depthOnThird = ParrotContainer(parent: depthOnSecond);

    expect(depthOnThird.root, container);
  });

  test("should create a child container from this container", () {
    final child = container.createChild();

    expect(child.parent, container);
  });

  group("register an instance", () {
    test("should register with singleton lifetime", () {
      container.register(
        Identifier.string("foo"),
        lifetime: InstanceLifetime.singleton(),
        provider: InstanceProvider.reflectClass<_Foo>(),
      );

      final first = container.get(Identifier.string("foo"));
      final second = container.get(Identifier.string("foo"));

      expect(first == second, true);
    });

    test("should register with transient lifetime", () {
      container.register(
        Identifier.string("foo"),
        lifetime: InstanceLifetime.transient(),
        provider: InstanceProvider.reflectClass<_Foo>(),
      );

      final first = container.get(Identifier.string("foo"));
      final second = container.get(Identifier.string("foo"));

      expect(first != second, true);
    });
  });

  group("returns whether an identifier is bound to instance", () {
    test("should return true if an identifier is bound to instance", () {
      container.register(
        Identifier.string("foo"),
        lifetime: InstanceLifetime.singleton(),
        provider: InstanceProvider.reflectClass(),
      );

      expect(container.has(Identifier.string("foo")), true);
    });

    test(
        "should return true if an identifier is bound to instance in parent container",
        () {
      container.register(
        Identifier.string("foo"),
        lifetime: InstanceLifetime.singleton(),
        provider: InstanceProvider.reflectClass(),
      );
      final child = container.createChild();

      expect(child.has(Identifier.string("foo")), true);
    });
  });
}

class _Foo {}
