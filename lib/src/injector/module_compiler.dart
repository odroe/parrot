import 'dart:mirrors';

import '../annotations/module.dart';
import 'any_compiler.dart';
import 'any_compiler_runner.dart';
import 'module_context.dart';

mixin ModuleCompiler on ModuleAnnotation implements AnyCompiler {
  @override
  Future<void> compile(AnyCompilerRunner runner, Mirror mirror) async {
    if (mirror is! ClassMirror) {
      throw Exception('@Module() annotation must be used on a class.');
    } else if (runner.container.containsKey(mirror.reflectedType)) {
      return;
    }

    // Register the instance to container.
    runner.container[mirror.reflectedType] = ModuleContext(
      container: runner.container,
      module: mirror.reflectedType,
      dependencies: dependencies,
      exports: exports,
      providers: providers,
    );

    // Compile the module dependencies.
    for (final Type dependency in dependencies) {
      if (dependency == mirror.reflectedType) continue;

      await runner.runAnyCompiler(dependency);
    }

    // TODO: Compile the module providers.
  }
}
