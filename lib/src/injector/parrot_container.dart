abstract class ParrotContainer {
  factory ParrotContainer() = _ParrotContainerImpl;

  /// Check if a value is in a container
  bool contains(Type type);

  /// Get a value from a container
  Object get(Type type);

  /// Register a value in a container
  void register<T extends Object>(T value);
}

class _ParrotContainerImpl implements ParrotContainer {
  _ParrotContainerImpl._();

  factory _ParrotContainerImpl() => _ParrotContainerImpl._()..instances = [];

  late final List<Object> instances;

  @override
  bool contains(Type type) =>
      instances.any((element) => element.runtimeType == type);

  @override
  Object get(Type type) =>
      instances.firstWhere((element) => element.runtimeType == type);

  @override
  void register<T extends Object>(T value) {
    instances
      ..removeWhere((element) => element.runtimeType == value.runtimeType)
      ..add(value);
  }
}
