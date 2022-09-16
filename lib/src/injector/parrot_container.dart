typedef InstanceFactory<T> = T Function();

/// 🦜 Parrot Container.
class ParrotContainer {
  final Map<Type, Object> _singletons = {};

  /// Returns a singleton instance of [T].
  Map<Type, Object> get singletons => _singletons;

  final Map<Type, Object Function()> _transients = {};

  /// Returns a factory instance of [T].
  Map<Type, InstanceFactory> get transients => _transients;

  /// Checks if [T] is registered.
  bool has(Type type) =>
      _singletons.containsKey(type) || transients.containsKey(type);

  /// Registers a singleton instance of [T].
  void registerSingleton<T extends Object>(T instance, [Type? type]) {
    _singletons[type ?? T] = instance;
  }

  /// Registers a factory instance of [T].
  void registerFactory<T extends Object>(InstanceFactory<T> factory,
      [Type? type]) {
    _transients[type ?? T] = factory;
  }

  /// Returns a singleton or factory instance of [T].
  T get<T extends Object>([Type? type]) {
    final instance = singletons[type ?? T];
    if (instance != null) {
      return instance as T;
    }

    final factory = transients[type ?? T];
    if (factory != null) {
      return factory() as T;
    }

    throw Exception('No instance of type $T found in container');
  }
}
