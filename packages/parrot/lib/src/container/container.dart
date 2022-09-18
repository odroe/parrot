import 'dart:mirrors';

abstract class ContainerSnapshot {
  bool has(Identifier identifier);

  bool hasByType<T>([Type? type]);

  T get<T>(Identifier identifier);

  T getByType<T>([Type? type]);

  T resolve<T>(ResolveInstanceRequest request);
}

/// Container is a container that holds instances and controls the lifecycle
/// of instances.
abstract class Container implements ContainerSnapshot {
  Container? get parent;

  Container get root;

  ContainerSnapshot get snapshot;

  Container createChild();

  void register(
    Identifier identifier, {
    required InstanceLifetime lifetime,
    required InstanceProvider provider,
  });

  void forget();
}

abstract class Identifier {
  Object get value;

  static Identifier string(String identifier) => _StringIdentifier(identifier);

  static Identifier object(String identifier) => _ObjectIdentifier(identifier);

  Object asKey();

  bool match(Identifier other);
}

class _StringIdentifier implements Identifier {
  const _StringIdentifier(this.identifier);

  final String identifier;

  @override
  Object get value => identifier;

  @override
  Object asKey() {
    return identifier;
  }

  @override
  bool match(Identifier other) {
    return other is _StringIdentifier && other.identifier == identifier;
  }
}

class _ObjectIdentifier implements Identifier {
  const _ObjectIdentifier(this.identifier);

  final Object identifier;

  @override
  Object get value => identifier;

  @override
  Object asKey() {
    return identifier;
  }

  @override
  bool match(Identifier other) {
    return other is _ObjectIdentifier && other.identifier == identifier;
  }
}

class InstanceSpec {
  const InstanceSpec({
    required this.identifier,
    required this.lifetime,
    required this.provider,
  });

  final Identifier identifier;

  final InstanceLifetime lifetime;

  final InstanceProvider provider;

  Type get instanceType => provider.instanceType;

  bool canResolveFor(Type type) => provider.canResolveFor(type);

  Object resolveFor(Type type, ContainerSnapshot snapshot) =>
      provider.resolveFor(type, snapshot);
}

abstract class InstanceLifetime {
  static InstanceLifetime singleton() => _SingletonLifetime();

  static InstanceLifetime transient() => _TransientLifetime();

  bool shouldCacheInstance(Object object);
}

class _SingletonLifetime implements InstanceLifetime {
  @override
  bool shouldCacheInstance(Object object) {
    return true;
  }
}

class _TransientLifetime implements InstanceLifetime {
  @override
  bool shouldCacheInstance(Object object) {
    return false;
  }
}

abstract class InstanceProvider {
  Type get instanceType;

  static InstanceProvider mirror<T>() => _MirrorProvider(T);

  static InstanceProvider value<T>(T value) => _ValueProvider<T>(value);

  bool canResolveFor(Type type);

  Object resolveFor(Type type, ContainerSnapshot snapshot);
}

class _MirrorProvider implements InstanceProvider {
  const _MirrorProvider(this.classType);

  final Type classType;

  @override
  Type get instanceType => classType;

  @override
  bool canResolveFor(Type type) {
    return reflectType(classType).isAssignableTo(reflectType(type));
  }

  @override
  Object resolveFor(Type type, ContainerSnapshot snapshot) {
    return reflectClass(classType).newInstance(Symbol(""), []).reflectee;
  }
}

class _ValueProvider<T> implements InstanceProvider {
  const _ValueProvider(this.value);

  final T value;

  Type get type => T;

  @override
  Type get instanceType => type;

  @override
  bool canResolveFor(Type type) {
    return type == this.type;
  }

  @override
  Object resolveFor(Type type, ContainerSnapshot snapshot) {
    return value as Object;
  }
}

class _FactoryProvider<T> implements InstanceProvider {
  const _FactoryProvider(
    this.dependencies,
    this.resolver,
  );

  final List<ResolveInstanceRequest> dependencies;

  final T Function(List<Object> dependencies) resolver;

  @override
  Type get instanceType => T;

  @override
  bool canResolveFor(Type type) {
    return type == T;
  }

  @override
  Object resolveFor(Type type, ContainerSnapshot snapshot) {
    return resolver(
            dependencies.map((dep) => snapshot.resolve(dep) as Object).toList())
        as Object;
  }
}

class Instance {
  const Instance(this.spec, this.object);

  final InstanceSpec spec;

  final Object object;
}

class ResolveInstanceRequest {
  const ResolveInstanceRequest(
    this.instanceType, {
    this.identifier,
    this.type,
  });

  final Identifier? identifier;

  final Type? type;

  final Type instanceType;
}

class MapCache<K, V> {
  final Map<K, V> entries = {};

  bool has(K key) {
    return entries.containsKey(key);
  }

  V? tryGet(K key, {V Function()? ifAbsent}) {
    return entries.containsKey(key) ? entries[key]! : ifAbsent?.call();
  }

  V mustGet(K key, {void Function()? ifThrow}) {
    if (!entries.containsKey(key)) {
      if (ifThrow != null) {
        ifThrow();
      }
      throw RangeError("out of range");
    }

    return entries[key]!;
  }

  V update(K key, V value) {
    entries[key] = value;
    return value;
  }

  V updateIfAbsent(K key, V value) {
    if (has(key)) {
      return mustGet(key);
    }

    return update(key, value);
  }

  void invalidate(K key) {
    entries.remove(key);
  }

  void invalidateAll() {
    entries.clear();
  }

  Map<K, V> toMap() {
    return Map.fromEntries(entries.entries);
  }
}

class ParrotContainer implements Container {
  ParrotContainer({
    this.parent,
  });

  @override
  final Container? parent;

  final MapCache<Object, InstanceSpec> identifierToInstanceSpecCache =
      MapCache();

  final Set<InstanceSpec> instanceSpecs = {};

  final MapCache<Object, Instance> identifierToInstanceCache = MapCache();

  final Set<Instance> instances = {};

  @override
  Container get root => parent?.root ?? this;

  @override
  Container createChild() {
    return ParrotContainer(parent: this);
  }

  @override
  void forget() {}

  @override
  bool has(Identifier identifier) {
    return instanceSpecs.any((spec) => identifier.match(spec.identifier));
  }

  @override
  bool hasByType<T>([Type? type]) {
    throw UnimplementedError();
  }

  @override
  T get<T>(Identifier identifier) {
    return _getOrResolveInstance<T>(ResolveInstanceRequest(
      T,
      identifier: identifier,
    ));
  }

  @override
  T getByType<T>([Type? type]) {
    return _getOrResolveInstance<T>(ResolveInstanceRequest(
      T,
      type: type ?? T,
    ));
  }

  T _getOrResolveInstance<T>(ResolveInstanceRequest request) {
    if (request.identifier != null &&
        identifierToInstanceCache.has(request.identifier!.asKey())) {
      return identifierToInstanceCache
          .mustGet(request.identifier!.asKey())
          .object as T;
    }

    return _resolveInstance<T>(
      request,
      shouldUpdateCache: true,
    );
  }

  void _registerInstanceSpec(
    Identifier identifier, {
    required InstanceLifetime lifetime,
    required InstanceProvider provider,
  }) {
    final instanceSpec = InstanceSpec(
      identifier: identifier,
      lifetime: lifetime,
      provider: provider,
    );

    instanceSpecs.add(instanceSpec);
    identifierToInstanceSpecCache.update(identifier.asKey(), instanceSpec);
  }

  void _registerInstance(InstanceSpec spec, Object object) {
    final instance = Instance(spec, object);

    instances.add(instance);
    identifierToInstanceCache.update(spec.identifier.asKey(), instance);
  }

  T _resolveInstance<T>(
    ResolveInstanceRequest request, {
    bool shouldUpdateCache = false,
  }) {
    final instanceSpec = matchInstanceSpecForResolve(request);

    final object = instanceSpec.resolveFor(request.instanceType, this);
    if (instanceSpec.lifetime.shouldCacheInstance(object)) {
      _registerInstance(instanceSpec, object);
    }

    return object as T;
  }

  // TODO: extract strategy
  InstanceSpec matchInstanceSpecForResolve(ResolveInstanceRequest request) {
    if (request.identifier != null &&
        identifierToInstanceSpecCache.has(request.identifier!.asKey())) {
      return identifierToInstanceSpecCache.mustGet(request.identifier!.asKey());
    }
    if (request.type != null) {
      return instanceSpecs
          .firstWhere((spec) => spec.canResolveFor(request.type!));
    }
    throw StateError("no matched InstantSpec");
  }

  @override
  void register(
    Identifier identifier, {
    required InstanceLifetime lifetime,
    required InstanceProvider provider,
  }) {
    _registerInstanceSpec(identifier, lifetime: lifetime, provider: provider);
  }

  @override
  T resolve<T>(ResolveInstanceRequest request) {
    return _getOrResolveInstance<T>(request);
  }

  @override
  ContainerSnapshot get snapshot => throw UnimplementedError();
}
