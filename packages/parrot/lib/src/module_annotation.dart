/// Module annotation.
class Module {
  /// Create a new [Module] instance.
  const Module({
    this.dependencies = const {},
    this.providers = const {},
    this.exports = const {},
    this.global = false,
    this.factory,
  });

  /// Module dependencies.
  final Set<Object> dependencies;

  /// Module providers.
  final Set<Object> providers;

  /// Module exports.
  final Set<Object> exports;

  /// The module is global.
  final bool global;

  /// The module class constructor or factory name.
  final String? factory;
}
