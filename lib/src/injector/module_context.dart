import '../annotations/module.dart';
import '../parrot_context.dart';
import 'parrot_container.dart';

class ModuleContext implements ParrotContext {
  ModuleContext({
    required this.container,
    required this.type,
    required this.annotation,
  });

  /// Current module annotation instance.
  final Module annotation;

  /// Parrot container.
  final ParrotContainer container;

  /// Current context module.
  final Type type;

  /// Metadata for other annotations of the module.
  final List<dynamic> metadata = [];

  @override
  T get<T extends Object>(Type type) {
    throw UnimplementedError();
  }

  @override
  T resolve<T extends Object>(Type type) {
    throw UnimplementedError();
  }

  @override
  ModuleContext select(Type module) {
    // If module is the same as the current module, return the current context.
    if (module == type) return this;

    // Find the module in dependencies.
    for (final Type dependency in annotation.dependencies) {
      try {
        return container.get<ModuleContext>(dependency).select(module);
      } catch (e) {
        continue;
      }
    }

    // Try find global modules.
    try {
      final ModuleContext context = container.get(module);

      if (context.type == module && context.annotation.global) return context;
    } catch (e) {
      throw Exception('The module $module is not found.');
    }

    throw Exception('The module $module is not found.');
  }
}
