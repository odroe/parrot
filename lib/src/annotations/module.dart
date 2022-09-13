/// Parrot module annotation.
///
/// A module is a class that contains bindings.
///
/// Example:
/// ```dart
/// @Module()
/// class AppModule {}
///
/// final app = ParrotApplication.create(AppModule);
/// ```
class Module {
  const Module({
    this.controllers = const [],
    this.providers = const [],
    this.imports = const [],
    this.exports = const [],
  });

  /// The module registed controllers.
  final Iterable<Type> controllers;

  /// The module registed service providers.
  final Iterable<Type> providers;

  /// The module imported modules.
  final Iterable<Type> imports;

  /// The module exported modules and services.
  final Iterable<Type> exports;
}
