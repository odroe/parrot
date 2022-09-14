import 'module_context.dart';
import 'parrot_container.dart';

class ModuleCompiler {
  const ModuleCompiler(this.container);
  final ParrotContainer container;

  /// Compile a module.
  ModuleContext compile(Type module) {
    throw UnimplementedError();
  }
}
