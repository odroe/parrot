import 'helpers/identifier.dart';
import 'instance.dart';

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
  Container createChild();

  void register({
    required InstanceLifetime lifetime,
    required InstanceProvider provider,
    Symbol name,
    List<Symbol> scopes,
    List<Type> aliasTypes,
  });

  void forget();

  ContainerSnapshot snapshot();
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

class ParrotContainer
    with Chain<ParrotContainer>, ScopedContainer
    implements Container {
  ParrotContainer({
    this.parent,
  });

  @override
  final ParrotContainer? parent;

  Set<InstanceSpec> get inheritedSharedInstanceSpecs =>
      Set.unmodifiable(sharedInstanceSpecs
          .followedBy(parent?.inheritedSharedInstanceSpecs ?? []));

  Set<InstanceSpec> get inheritedInstanceSpecs => Set.unmodifiable(
      localInstanceSpecs.followedBy(inheritedSharedInstanceSpecs));

  Set<Instance> get inheritedSharedInstances => Set.unmodifiable(
      sharedInstances.followedBy(parent?.inheritedSharedInstances ?? []));

  Set<Instance> get inheritedInstances =>
      Set.unmodifiable(localInstances.followedBy(inheritedSharedInstances));

  @override
  Container createChild() {
    return ParrotContainer(parent: this);
  }

  @override
  void forget() {}

  @override
  bool has(Identifier identifier) {
    return instanceSpecs.any((spec) => identifier.match(spec.name));
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
      name: identifier,
      lifetime: lifetime,
      provider: provider,
    );

    instanceSpecs.add(instanceSpec);
    identifierToInstanceSpecCache.updater(identifier.asKey(), instanceSpec);
  }

  void _registerInstance(InstanceSpec spec, Object object) {
    final instance = Instance(spec, object);

    instances.add(instance);
    identifierToInstanceCache.updater(spec.name.asKey(), instance);
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
  ContainerSnapshot snapshot() {
    throw UnimplementedError();
  }
}

abstract class ScopedContainer implements Container {
  final Set<InstanceSpec> localInstanceSpecs = {};

  final Set<InstanceSpec> sharedInstanceSpecs = {};

  Set<InstanceSpec> get instanceSpecs =>
      Set.unmodifiable(localInstanceSpecs.followedBy(sharedInstanceSpecs));

  final Set<Instance> localInstances = {};

  final Set<Instance> sharedInstances = {};

  Set<Instance> get instances =>
      Set.unmodifiable(localInstances.followedBy(sharedInstances));
}

abstract class Chain<T extends Chain<T>> {
  T? get parent;

  T get root => parent?.root ?? (this as T);
}
