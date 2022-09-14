/// Parrot context.
///
/// The context is a container for modules.
abstract class ParrotContext {
  /// Select a module from the current context node. And search from the
  /// modules exported by the current module.
  ///
  /// If the module is not found, throw an error.
  ParrotContext select(Type module);

  /// Get a provider injected instance from the current context node.
  ///
  /// If the provider is not found, throw an error.
  T get<T extends Object>(Type type);

  /// Get an instance or module, and retrieve dependencies if they don't
  /// exist in the current context.
  T resolve<T extends Object>(Type type);
}
