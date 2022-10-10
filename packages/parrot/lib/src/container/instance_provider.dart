import 'instance_factory.dart';

/// Instance provider.
abstract class InstanceProvider<T> {
  /// Instance factory.
  InstanceFactory<T> get factory;

  /// Instance token.
  Object get token;
}

/// Lazy instance provider.
///
/// The provider is lazy load the instance.
class LazyInstanceProvider<T> implements InstanceProvider<T> {
  /// Create a new [LazyInstanceProvider] instance.
  const LazyInstanceProvider({
    required this.factory,
    required this.token,
  });

  @override
  final InstanceFactory<T> factory;

  @override
  final Object token;
}

/// Eager instance provider.
///
/// The provider is eager load the instance.
class EagerInstanceProvider<T> implements InstanceProvider<T> {
  /// Create a new [EagerInstanceProvider] instance.
  const EagerInstanceProvider({
    required this.factory,
    required this.token,
  });

  @override
  final InstanceFactory<T> factory;

  @override
  final Object token;
}
