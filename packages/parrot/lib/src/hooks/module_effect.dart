library parrot.core.hooks;

import '../_internal/internal_effect_module_wrapper.dart';
import '../modular.dart';

part '../_internal/hooks/effect_module_wrapper_impl.dart';

/// Use Module effect.
///
/// Effects allow modules to run code for some custom actions after
/// being loaded into Parrot.
abstract class UseModuleEffect {
  /// Define a effect provider.
  ///
  /// This provider is not exposed to the module, but is evaluated after the module is loaded into Parrot.
  Provider<void> get effect;
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
  /// ).useEffect((ref) {
  ///   // Do something.
  /// });
  /// ```
  Module useEffect(Provider<void> effect) =>
      _EffectModuleWrapperImpl(this, effect);
}

final module = Module().useEffect((ref) => null);
