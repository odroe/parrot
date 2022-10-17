part of parrot.core.modular;

/// Named provider implementation.
class _NamedProviderImpl<T> implements NamedProvider<T> {
  /// Creates a named provider.
  const _NamedProviderImpl(this.name, this.provider);

  /// Super provider.
  @override
  final Provider<T> provider;

  @override
  FutureOr<T> call(ModuleRef ref) => provider(ref);

  @override
  final Object name;

  @override
  Provider<T> named(Object name) => _NamedProviderImpl(name, this);
}
