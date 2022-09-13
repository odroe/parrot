/// Parrot context.
///
/// The context is a container for modules.
abstract class ParrotContext<T> {
  const ParrotContext();

  /// Retrieves the specified module from the current context.
  ///
  /// If the module is not found, an exception is thrown.
  ///
  /// Example:
  /// ```dart
  /// final context = app.select<ModuleA>();
  /// ```
  ParrotContext<S> select<S>();

  /// Retrieves an instance of either injectable or controller, otherwise, throws exception.
  ///
  /// Example:
  /// ```dart
  /// final controller = app.get<ControllerA>();
  /// ```
  S get<S>();
}
