library parrot.core.hooks;

import '../modular.dart';

part '../_internal/hooks/effect_module_wrapper_impl.dart';

/// Module effect next.
///
/// Call next effect.
typedef ModuleEffectNext = Future<void> Function();

/// Module effect.
typedef ModuleEffect = Future<void> Function(
    ModuleRef ref, ModuleEffectNext next);

/// Use Module effect.
///
/// Effects allow modules to run code for some custom actions after
/// being loaded into Parrot.
abstract class UseModuleEffect {
  /// Module effect.
  ///
  /// * [ref] is the module reference.
  /// * [next] is the next effect.
  Future<void> effect(ModuleRef ref, ModuleEffectNext next);
}

/// Module effect extension.
extension ModuleEffectExtension on Module {
  /// Use module effect.
  ///
  /// ```dart
  /// final module = Module(
  ///   providers: { ... },
  ///   imports: { ... },
  ///   exports: { ... },
  /// ).useEffect((ref, next) async {
  ///   // Do something.
  /// });
  /// ```
  Module useEffect(ModuleEffect effect) =>
      _EffectModuleWrapperImpl(this, effect);
}
