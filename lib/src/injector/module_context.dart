import '../annotations/module.dart';
import '../container/parrot_container.dart';
import '../container/parrot_token.dart';
import '../exceptions/module_not_found_exception.dart';
import '../parrot_context.dart';

typedef ModuleContextToken = InstanceToken<ModuleContext>;

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

    final ParrotToken? token = _container.get(module);
    if (token != null && token is ModuleContextToken) {
      if (token.value.global || hasModuleDependency(module)) {
        return token.value;
      }
    }

    throw ModuleNotFoundException(module);
  }

  /// Has a module in dependencies.
  bool hasModuleDependency(Type module) {
    for (final Type dependency in dependencies) {
      // If the module is in dependencies, return true.
      if (dependency == module) return true;

      final ParrotToken? token = _container.get(dependency);
      if (token != null && token is ModuleContextToken) {
        // If the module is in dependencies, return true.
        if (token.value.hasModuleDependency(module)) return true;
      }
    }

    return false;
  }
}
