/// Module annotation.
abstract class Module {
  const Module({
    this.dependencies = const {},
    this.providers = const {},
    this.exports = const {},
    this.factory,
    this.global = false,
  });

  /// Dependency modules.
  final Set<Object> dependencies;

  /// Service providers.
  final Set<Object> providers;

  /// Export module and providers.
  final Set<Object> exports;

  /// Module factory method name.
  final String? factory;

  /// The module is global.
  final bool global;
}
