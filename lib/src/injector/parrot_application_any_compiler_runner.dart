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

    /// Get all [AnyCompiler] annotations.
    final Iterable<AnyCompiler> annotations = mirror.metadata
        .map((InstanceMirror annotation) => annotation.reflectee)
        .whereType<AnyCompiler>();

    print(annotations);
  }
}
