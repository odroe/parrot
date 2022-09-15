import 'dart:mirrors';

import '../container/parrot_container.dart';
import 'any_compiler.dart';

abstract class AnyCompilerRunner {
  factory AnyCompilerRunner(ParrotContainer container) = _AnyCompilerRunnerImpl;

  /// Run all [AnyCompiler] compile annotations.
  Future<void> runAnyCompiler(Type type);

  /// Current container.
  ParrotContainer get container;
}

class _AnyCompilerRunnerImpl implements AnyCompilerRunner {
  _AnyCompilerRunnerImpl(this.container);

  @override
  final ParrotContainer container;

  @override
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
