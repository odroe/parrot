import 'dart:async';

import '../hooks/module_effect.dart';
import '../modular.dart';
import 'internal_effect_module_wrapper.dart';
import 'modular_tracker.dart';
import 'module_container.dart';

abstract class ModuleEffectCall {
  /// Call effect and return modular tracker.
  FutureOr<ModularTracker> call();

  /// Create a new [ModuleEffectCall] instance.
  factory ModuleEffectCall(ModularTracker tracker) = _ModuleEffectCallImpl;
}

/// Module effect call implementation.
class _ModuleEffectCallImpl implements ModuleEffectCall {
  _ModuleEffectCallImpl(this.tracker);

  final ModularTracker tracker;

  ModuleConatiner get container => tracker.container;

  @override
  FutureOr<ModularTracker> call() async =>
      callEffect(tracker).then((void_) => tracker);

  final Set<ModularTracker> _visited = <ModularTracker>{};

  Future<void> callEffect(ModularTracker tracker) async {
    // If the module is already visited, return.
    if (_visited.contains(tracker)) return;

    // Mark the module as visited.
    _visited.add(tracker);

    // Call import modules effect.
    for (final Module module in tracker.module.imports) {
      final ModularTracker tracker =
          ModularTracker.lookup(module: module, container: container);

      await callEffect(tracker);
    }

    // Call self effect.
    if (tracker.module is UseModuleEffect) {
      final UseModuleEffect effectModule = tracker.module as UseModuleEffect;
      final ModularTracker realTracker = resolveRealTracker(tracker);

      await effectModule.effect(realTracker);
    }
  }

  ModularTracker resolveRealTracker(ModularTracker tracker) {
    final Module module = tracker.module;
    final ModuleConatiner container = tracker.container;

    if (module is InternalEffectModuleWrapper) {
      final InternalEffectModuleWrapper wrapper =
          module as InternalEffectModuleWrapper;
      final ModularTracker tracker = ModularTracker.lookup(
        module: wrapper.module,
        container: container,
      );

      return resolveRealTracker(tracker);
    }

    return tracker;
  }
}
