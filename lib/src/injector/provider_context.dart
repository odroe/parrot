abstract class ProviderContext<T> {
  const ProviderContext({
    required this.modules,
    required this.provider,
  });

  /// Modules described by the current provider.
  final List<Type> modules;

  /// The provider type
  final Type provider;

  /// Remove the provider instance.
  Future<T> resolve();
}

/// Instance provider context.
class SingletonProviderContext<T> extends ProviderContext<T> {
  const SingletonProviderContext({
    required super.modules,
    required super.provider,
    required this.instance,
  });

  /// The provider instance.
  final T instance;

  @override
  Future<T> resolve() async => instance;
}

/// Transient provider context.
class TransientProviderContext<T> extends ProviderContext<T> {
  const TransientProviderContext({
    required super.modules,
    required super.provider,
    required this.factory,
  });

  /// The provider value.
  final Future<T> Function() factory;

  @override
  Future<T> resolve() => factory();
}

/// Request provider context.
class RequestProviderContext<T> extends ProviderContext<T> {
  const RequestProviderContext({
    required super.modules,
    required super.provider,
    required this.factory,
  });

  /// The provider value.
  final Future<T> Function() factory;

  @override
  Future<T> resolve() => factory();
}
