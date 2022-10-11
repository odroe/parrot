abstract class ModuleRef {
  /// Select other modules or global modules in the current module scope.
  Future<ModuleRef> select(Object token);

  /// Finds a provider instance for the current module scope or a provider
  /// instance for a global module.
  Future<T> find<T>(Object token);
}
