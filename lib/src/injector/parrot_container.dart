import '../exceptions/instance_not_found_exception.dart';

abstract class ParrotContainer {
  factory ParrotContainer() = _ParrotContainerImpl;

  /// Check if a value is in a container
  bool contains(Type type);

  /// Get a value from a container
  T get<T extends Object>(Type type);

  /// Register a value in a container
  void register<T extends Object>(Type type, T value);
}

class _ParrotContainerImpl implements ParrotContainer {
  _ParrotContainerImpl._();

  factory _ParrotContainerImpl() => _ParrotContainerImpl._();

  final Map<Type, Object> instances = {};

  @override
  bool contains(Type type) => instances.containsKey(type);

  @override
  T get<T extends Object>(Type type) {
    if (contains(type)) {
      final Object result = instances[type]!;
      if (result is T) {
        return result;
      }
    }

    throw InstanceNotFoundException(type);
  }

  @override
  void register<T extends Object>(Type type, T value) {
    instances[type] = value;
  }
}
