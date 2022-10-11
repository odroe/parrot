class ModuleMetadata {
  const ModuleMetadata({
    this.dependencies = const {},
    this.providers = const {},
    this.exports = const {},
    this.global = false,
  });

  /// Module dependencies.
  final Set<Object> dependencies;

  /// Module providers.
  final Set<Object> providers;

  /// Module exports.
  final Set<Object> exports;

  /// The module is global.
  final bool global;
}
