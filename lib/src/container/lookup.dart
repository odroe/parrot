class Lookup {
  Map<Type, dynamic> instances = {};

  void register<TInstance>(Type type, TInstance instance) {
    instances[type] = instance;
  }

  bool has(Type type) {
    return instances.containsKey(type);
  }

  TInstance get<TInstance>(Type type) {
    return instances[type];
  }
}
