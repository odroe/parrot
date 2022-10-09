import 'instance_factory.dart';

/// Instance provider.
abstract class Provider<T> {
  /// Instance factory.
  InstanceFactory<T> get factory;

  /// Instance token.
  Object get token;
}

/// Lazy provider.
///
/// The provider is lazy load the instance.
class LazyProvider<T> implements Provider<T> {
  /// Create a new [LazyProvider] instance.
  const LazyProvider({
    required this.factory,
    required this.token,
  });

  @override
  final InstanceFactory<T> factory;

  @override
  final Object token;
}

/// Eager provider.
///
/// The provider is eager load the instance.
class EagerProvider<T> implements Provider<T> {
  /// Create a new [EagerProvider] instance.
  const EagerProvider({
    required this.factory,
    required this.token,
  });

  @override
  final InstanceFactory<T> factory;

  @override
  final Object token;
}
