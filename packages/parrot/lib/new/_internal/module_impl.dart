part of parrot.core.modular;

/// [Module] implementation.
class _ModuleImpl implements Module {
  /// Create a new [Module] instance.
  const _ModuleImpl({
    this.imports = const <Module>{},
    this.providers = const <Provider>{},
    this.exports = const <Object>{},
  });

  @override
  final Set<Object> exports;

  @override
  final Set<Module> imports;

  @override
  final Set<Provider> providers;
}
