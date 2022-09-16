import 'dart:mirrors';

import '../annotations/module.dart';
import 'module_context.dart';
import 'parrot_container.dart';

/// Module compiler.
class ModuleCompiler {
  const ModuleCompiler(this.container);

  /// Parrot container.
  final ParrotContainer container;

  /// Compile module to module context.
  Future<ModuleContext> compile(Type module) async {
    final ClassMirror classMirror = reflectClass(module);

    // Check whether the metadata of the [classMirror] contains only one '@Module()', and no or more than one error is thrown.
    final List<Module> moduleAnnotations = classMirror.metadata
        .whereType<InstanceMirror>()
        .map((InstanceMirror instanceMirror) => instanceMirror.reflectee)
        .whereType<Module>()
        .toList();
    if (moduleAnnotations.length != 1) {
      throw StateError(
          'The module $module must have only one `@Module()` annotation.');
    }

    // If the context of the current module exists in the container, return it.
    if (container.has(module)) {
      return container.get(module);
    }

    // Create a new module context.
    final ModuleContext context = ModuleContext(
      container: container,
      type: module,
      annotation: moduleAnnotations.first,
    );
    container.registerSingleton(context, module);

    // Compile dependencies modules.
    for (final Type dependency in context.annotation.dependencies) {
      await compile(dependency);
    }

    // Return the module context.
    return context;
  }
}
