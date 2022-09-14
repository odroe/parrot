import 'dart:mirrors';

import '../annotations/module.dart';
import '../exceptions/module_not_found_exception.dart';
import '../exceptions/instance_not_found_exception.dart';
import '../parrot_context.dart';
import '../parrot_container.dart';

abstract class ModuleContext extends Module implements ParrotContext {
  const ModuleContext({
    required this.module,
    super.dependencies,
    super.providers,
    super.exports,
  });

  factory ModuleContext.compile(ParrotContainer container, Type module) =
      _ModuleCompiler.factory;

  /// Current context module.
  final Type module;
}

class _ModuleContextImpl extends ModuleContext {
  _ModuleContextImpl({
    required this.container,
    required super.module,
    super.dependencies,
    super.exports,
    super.providers,
  });

  final ParrotContainer container;

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
      final ModuleContext context = container[module] as ModuleContext;

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
        final _ModuleContextImpl context =
            container[dependency] as _ModuleContextImpl;
        if (context.hasModuleDependency(module)) return true;
      } catch (e) {
        continue;
      }
    }

    return false;
  }
}

class _ModuleCompiler extends _ModuleContextImpl {
  _ModuleCompiler({
    required super.container,
    required super.module,
    super.dependencies,
    super.exports,
    super.providers,
  });

  factory _ModuleCompiler.factory(ParrotContainer container, Type module) {
    // If the module is already compiled, return it.
    if (container.containsKey(module)) {
      return container[module] as _ModuleCompiler;
    }

    final ClassMirror classMirror = reflectClass(module);
    final _ModuleCompiler instance = createContext(classMirror, container);

    // Register the instance to container.
    container[module] = instance;

    // Compile the module dependencies.
    for (final Type dependency in instance.dependencies) {
      _ModuleCompiler.factory(container, dependency);
    }

    // Compile the module providers.
    // for (final Type provider in context.providers) {
    //   compile(container, provider);
    // }

    return instance;
  }

  /// Create a module context.
  static _ModuleCompiler createContext(
    ClassMirror classMirror,
    ParrotContainer container,
  ) {
    // Get module annotation.
    final Module annotation = findModuleAnnotation(classMirror);

    // Create module context.
    return _ModuleCompiler(
      container: container,
      module: classMirror.reflectedType,
      dependencies: annotation.dependencies,
      providers: annotation.providers,
      exports: annotation.exports,
    );
  }

  /// Find a module annotation.
  static Module findModuleAnnotation(ClassMirror classMirror) {
    final Iterable<InstanceMirror> metadata =
        classMirror.metadata.where((element) => element.reflectee is Module);

    if (metadata.isEmpty) {
      throw ArgumentError('The module must be annotated with @Module()');
    } else if (metadata.length > 1) {
      throw ArgumentError(
          'The module must be annotated with only one @Module()');
    }

    return metadata.first.reflectee;
  }
}
