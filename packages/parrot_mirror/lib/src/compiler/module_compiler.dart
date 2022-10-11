import 'dart:mirrors';
import 'package:parrot/parrot.dart';

import 'compiler.dart';

mixin ModuleCompiler on Compiler {
  @override
  Future<ModuleContext> compileModule(Object module,
      [ModuleContext? parent]) async {
    final Object moduleToken = _resolveModuleClassToken(module);

    // If the module has been compiled, return the module context.
    if (container.has(moduleToken)) {
      return container.getInstance(moduleToken);
    }

    // Create module context.
    final ModuleContext context = ModuleContext(
      metadata: await _resolveModuleMetadata(module, parent),
      token: moduleToken,
      parent: parent,
    );

    // Save module context to container.
    container.addInstanceContext(context);

    /// Compile module context and return it.
    return compileModuleContext(module, context);
  }

  /// Compile module context.
  Future<ModuleContext> compileModuleContext(
      Object module, ModuleContext context) async {
    // If module is a [DynamicModule], Set factory.
    if (module is DynamicModule) {
      context.factory = () async => module;
    }

    // Validate module cyclic dependency.
    if (validateModuleCyclicDependency(context)) {
      printModuleCyclicDependency(context);
    }

    // Compile module dependencies.
    await _compileModuleDependencies(context);

    // Compile module providers.
    await _compileModuleProviders(context);

    // Module is is [Type], Creare module instalce factory.
    if (module is Type) {
      context.factory = await createModuleInstanceFactory(module, context);
    }

    return context;
  }

  /// Compile module providers.
  Future<void> _compileModuleProviders(ModuleContext context) async {
    for (final Object provider in context.metadata.providers) {
      await compileProvider(provider, context);
    }
  }

  /// Create module instance factory.
  Future<InstanceFactory<T>> createModuleInstanceFactory<T>(
      Type module, ModuleContext context) async {
    // Create class provider.
    final ClassProvider classProvider = ClassProvider(
      useClass: module,
      token: context,
    );

    // Compile class provider.
    final InstanceContext<T> instanceContext =
        await compileProvider<T>(classProvider, context);

    // Return instance factory.
    return instanceContext.factory;
  }

  /// Resolve module metadata.
  Future<ModuleMetadata> _resolveModuleMetadata(Object module,
      [ModuleContext? parent]) async {
    if (module is DynamicModule) {
      return _resolveDynamicModuleMetadata(module, parent);

      // If module is not a [Type], throw an exception.
    } else if (module is! Type) {
      throw ArgumentError.value(module, 'module',
          'Module must be a [Type] or [DynamicModule] implementation instance.');
    }

    return _findModuleAnnotation(module);
  }

  /// Find module annotation.
  ModuleMetadata _findModuleAnnotation(Type module) {
    final ClassMirror classMirror = reflectClass(module);
    final Iterable<Module> moduleAnnotations = classMirror.metadata
        .whereType<InstanceMirror>()
        .map((e) => e.reflectee)
        .whereType<Module>();
    if (moduleAnnotations.length != 1) {
      throw ArgumentError.value(module, 'module',
          'Module must be annotated with a single [Module] annotation.');
    }

    return moduleAnnotations.single;
  }

  /// Resolve module metadata from dynamic module.
  Future<ModuleMetadata> _resolveDynamicModuleMetadata(DynamicModule module,
      [ModuleContext? parent]) async {
    // If the module has been compiled, return the module.
    if (container.has(module)) {
      return module;
    }

    // Create module context.
    final ModuleContext context = ModuleContext(
      metadata: module,
      token: module,
      parent: parent,
    );

    // Compile module context.
    await compileModuleContext(module, context);

    // Create override module metadata.
    final ModuleMetadata? override = await module.overrideMetadata(context);

    // Resolve module metadata.
    final ModuleMetadata metadata = override ?? module;

    // Resolve module origin metadata.
    final ModuleMetadata original = await _resolveModuleMetadata(module.module);

    // Create resolved module metadata.
    return ModuleMetadata(
      dependencies: {...original.dependencies, ...metadata.dependencies},
      providers: {...original.providers, ...metadata.providers},
      exports: {...original.exports, ...metadata.exports},
      global: metadata.global || original.global,
    );
  }

  /// Resolve module class token.
  Object _resolveModuleClassToken(Object module) {
    // If module is [Type], return it.
    if (module is Type) {
      return module;

      // If module is dynamic module, return its token.
    } else if (module is DynamicModule) {
      return module.module;
    }

    return module;
  }

  /// Compile module dependencies.
  Future<void> _compileModuleDependencies(ModuleContext context) async {
    for (final Object dependency in context.metadata.dependencies) {
      await compileModule(dependency, context);
    }
  }
}
