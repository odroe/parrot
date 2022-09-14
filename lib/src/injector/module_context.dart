import '../annotations/module.dart';
import '../exceptions/module_not_found_exception.dart';
import '../exceptions/instance_not_found_exception.dart';
import '../parrot_context.dart';
import 'parrot_container.dart';

abstract class ModuleContext extends Module implements ParrotContext {
  const ModuleContext._({
    required this.module,
    super.dependencies,
    super.providers,
    super.exports,
  });

  factory ModuleContext({
    required ParrotContainer container,
    required Type module,
    List<Type> dependencies,
    List<Type> providers,
    List<Type> exports,
  }) = _ModuleContextImpl;

  final Type module;
}

class _ModuleContextImpl extends ModuleContext {
  _ModuleContextImpl({
    required this.container,
    required Type module,
    List<Type> dependencies = const [],
    List<Type> providers = const [],
    List<Type> exports = const [],
  }) : super._(
          module: module,
          dependencies: dependencies,
          providers: providers,
          exports: exports,
        );

  final ParrotContainer container;

  @override
  T get<T extends Object>(Type type) {
    if (hasProvider(type)) {
      return container.get<T>(type);
    }

    throw InstanceNotFoundException(type);
  }

  @override
  ParrotContext select(Type module) {
    try {
      // Get the module context from container.
      final ModuleContext context = container.get<ModuleContext>(module);

      // If the module context is not current exports, throw an error.
      if (hasExported(module)) return context;
    } on InstanceNotFoundException {
      throw ModuleNotFoundException(module);
    }

    throw ModuleNotFoundException(module);
  }

  @override
  T resolve<T extends Object>(Type type) {
    if (hasExported(type) || hasProvider(type) || hasDependency(type)) {
      return container.get<T>(type);
    }

    throw InstanceNotFoundException(type);
  }

  /// Has the is dependency.
  bool hasDependency(Type type) {
    // If the type contains in dependencies, return true.
    if (dependencies.contains(type)) return true;

    for (final Type dependency in dependencies) {
      try {
        final _ModuleContextImpl context =
            container.get<_ModuleContextImpl>(dependency);

        if (context.hasDependency(type)) return true;
      } catch (e) {
        continue;
      }
    }

    return false;
  }

  /// Has the type is provider.
  bool hasProvider(Type type) => providers.contains(type);

  /// Has the type exported.
  bool hasExported(Type type) {
    for (final Type export in exports) {
      try {
        final _ModuleContextImpl context =
            container.get<_ModuleContextImpl>(export);

        if (context.hasExported(type)) return true;
      } catch (e) {
        continue;
      }
    }

    return false;
  }
}
