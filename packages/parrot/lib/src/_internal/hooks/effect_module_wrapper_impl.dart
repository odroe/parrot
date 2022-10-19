part of parrot.core.hooks;

/// Effect module wrapper.
class _EffectModuleWrapperImpl implements Module, UseModuleEffect {
  /// Create a new [_EffectModuleWrapperImpl] instance.
  const _EffectModuleWrapperImpl(this._module, this._effect);

  final ModuleEffect _effect;
  final Module _module;

  @override
  Set<Object> get exports => _module.exports;

  @override
  Set<Module> get imports => _module.imports;

  @override
  Set<Provider> get providers => _module.providers;

  @override
  Future<void> effect(ModuleRef ref, ModuleEffectNext next) =>
      _effect(ref, _resolveEffectNext(ref, next));

  ModuleEffectNext _resolveEffectNext(ModuleRef ref, ModuleEffectNext next) {
    if (_module is UseModuleEffect) {
      final UseModuleEffect effectModule = _module as UseModuleEffect;

      return () => effectModule.effect(ref, next);
    }

    return next;
  }
}
