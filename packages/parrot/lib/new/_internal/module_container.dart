import 'dart:collection';

import '../exception.dart';
import '../modular.dart';
import 'modular_tracker.dart';

/// Module container.
class ModuleConatiner extends IterableBase<ModularTracker> {
  /// Modular tracker stack.
  final Set<ModularTracker> _stack = <ModularTracker>{};

  @override
  Iterator<ModularTracker> get iterator => _stack.iterator;

  /// Register a [ModularTracker] instance.
  void register(ModularTracker tracker) => _stack.add(tracker);

  /// Has a [module] in the stack.
  bool has(Module module) => _stack.any((tracker) => tracker.module == module);

  /// Returns the [tracker] for the given [module].
  ModularTracker get(Module module) => _stack.firstWhere(
        (tracker) => tracker.module == module,
        orElse: () => throw ParrotModuleNotFoundException(module),
      );
}
