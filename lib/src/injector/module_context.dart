import '../annotations/module.dart';
import '../exceptions/module_not_found_exception.dart';
import '../exceptions/instance_not_found_exception.dart';
import '../parrot_context.dart';
import '../parrot_container.dart';

class ModuleContext extends Module implements ParrotContext {
  const ModuleContext({
    required ParrotContainer container,
    required this.module,
    required super.dependencies,
    required super.providers,
    required super.exports,
  }) : _container = container;

  final ParrotContainer _container;

  /// Current context module.
  final Type module;

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
    if (module == this.module) return this;

    try {
      // Get the module context from container.
      final ModuleContext context = _container[module] as ModuleContext;

      // If the module context is not current exports, throw an error.
      if (context.global || hasModuleDependency(module)) return context;
    } on InstanceNotFoundException {
      throw ModuleNotFoundException(module);
    }

    throw ModuleNotFoundException(module);
  }

  /// Has a module in dependencies.
  bool hasModuleDependency(Type module) {
    for (final Type dependency in dependencies) {
      // If the module is in dependencies, return true.
      if (dependency == module) return true;

      try {
        final ModuleContext context = _container[dependency] as ModuleContext;
        if (context.hasModuleDependency(module)) return true;
      } catch (e) {
        continue;
      }
    }

    return false;
  }
}
