part of parrot.core.hooks;

/// Effect module wrapper.
class _EffectModuleWrapperImpl
    implements Module, UseModuleEffect, InternalEffectModuleWrapper {
  /// Create a new [_EffectModuleWrapperImpl] instance.
  const _EffectModuleWrapperImpl(this.module, this.effect);

  /// Module that need to be wrapped.
  @override
  final Module module;

  @override
  final Provider<void> effect;

  @override
  Set<Object> get exports => {module};

  @override
  Set<Module> get imports => {module};

  @override
  Set<Provider> get providers => const {};
}
