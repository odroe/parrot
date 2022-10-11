import 'container/instance_context.dart';
import 'module_context.dart';
import 'parrot_application.dart';

abstract class ParrotCompiler {
  const ParrotCompiler();

  /// Setup the compiler.
  set application(ParrotApplication application);

  /// Compile a module.
  Future<ModuleContext> compileModule(Object module, [ModuleContext? parent]);

  /// Compile a provider.
  Future<InstanceContext<T>> compileProvider<T>(
      Object provider, ModuleContext context);
}

/// Module cyclic dependency extension.
extension ModuleCyclicDependency on ParrotCompiler {
  /// Validate module cyclic dependency.
  bool validateModuleCyclicDependency(ModuleContext context) {
    ModuleContext? parent = context.parent;
    while (parent != null) {
      if (parent.token == context.token) {
        return true;
      }
      parent = parent.parent;
    }
    return false;
  }

  /// Print module cyclic dependency.
  Never printModuleCyclicDependency(ModuleContext context) {
    final List<String> modules = [];
    ModuleContext? parent = context.parent;
    while (parent != null) {
      modules.add(parent.token.toString());
      parent = parent.parent;
    }
    modules.add(context.token.toString());
    print('Module cyclic dependency: ${modules.join(' -> ')}');

    throw Exception('Module cyclic dependency.');
  }
}
