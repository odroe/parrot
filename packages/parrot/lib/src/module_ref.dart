abstract class ModuleRef {
  /// Select other modules or global modules in the current module scope.
  ModuleRef select(Object module);

  /// Finds a provider instance for the current module scope or a provider
  /// instance for a global module.
  Future<T> find<T>(Object provider);
}
