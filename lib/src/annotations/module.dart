/// Parrot module annotation.
///
/// A module is a class that contains bindings.
///
/// Example:
/// ```dart
/// @Module(
///   dependencies: [ModuleA, ModuleB],
/// )
/// class AppModule {}
///
/// final app = ParrotApplication(AppModule);
/// ```
class Module {
  const Module({
    this.dependencies = const [],
    this.providers = const [],
    this.exports = const [],
  });

  /// The module registed service providers.
  final Iterable<Type> providers;

  /// The module dependency modules.
  final Iterable<Type> dependencies;

  /// Exported providers and dependencies.
  final Iterable<Type> exports;
}
