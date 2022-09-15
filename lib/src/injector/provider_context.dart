abstract class ProviderContext<T> {
  const ProviderContext({
    required this.modules,
    required this.type,
    required this.value,
  });

  /// Modules described by the current provider.
  final List<Type> modules;

  /// The provider type
  final Type type;

  /// The provider value
  final T value;
}
