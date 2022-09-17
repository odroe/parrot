import 'dart:mirrors';

import '../annotations/module.dart';
import '../container/parrot_container.dart';
import '../container/parrot_token.dart';
import '../utils/typed_symbol.dart';
import 'module_context.dart';

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

    // Create the module symbol.
    final Symbol moduleSymbol = TypedSymbol.create(module);

    // If the context of the current module exists in the container, return it.
    if (container.has(moduleSymbol)) {
      return container.get<ModuleContext>(moduleSymbol).resolve();
    }

    // Create a new module context.
    final ModuleContext context = ModuleContext(
      container: container,
      type: module,
      annotation: moduleAnnotations.first,
    );
    container.register(SingletonToken(moduleSymbol, context));

    // Compile dependencies modules.
    for (final Type dependency in context.annotation.dependencies) {
      context.metadata.add(await compile(dependency));
    }

    // Return the module context.
    return context;
  }
}
