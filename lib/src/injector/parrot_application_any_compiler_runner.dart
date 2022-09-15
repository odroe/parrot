import 'dart:mirrors';

import 'package:meta/meta.dart';

import '../parrot_application.dart';
import 'any_compiler.dart';
import 'any_compiler_runner.dart';

mixin ParrotApplicationAnyCompilerRunner on ParrotApplicationBase
    implements AnyCompilerRunner {
  @override
  Future<void> initialize() async {
    // Register the application to container.
    container.putIfAbsent(ParrotApplication, () => this);

    // Compile the application module.
    await runAnyCompiler(module);

    return super.initialize();
  }

  @override
  @internal
  Future<void> runAnyCompiler(Type type) async {
    final TypeMirror mirror = reflectType(type);

    // Get all [AnyCompiler] annotations from the [type].
    final List<AnyCompiler> annotations = mirror.metadata
        .map((InstanceMirror annotation) => annotation.reflectee)
        .whereType<AnyCompiler>()
        .toList();

    // Sort the annotations by [uses].
    annotations.sort((AnyCompiler a, AnyCompiler b) {
      if (a.uses.contains(b.runtimeType)) return 1;
      if (b.uses.contains(a.runtimeType)) return -1;
      return 0;
    });

    // Run the annotations.
    for (final AnyCompiler anyCompiler in annotations) {
      for (final Type use in anyCompiler.uses) {
        if (!annotations.map((e) => e.runtimeType).contains(use)) {
          throw Exception(
              'The annotation ${anyCompiler.runtimeType} depends on the annotation $use, but the annotation $use is not found.');
        }
      }

      await anyCompiler.compile(this, mirror);
    }
  }
}
