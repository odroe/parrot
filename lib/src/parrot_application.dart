import 'injector/module_compiler.dart';
import 'injector/module_context.dart';
import 'injector/parrot_container.dart';
import 'parrot_context.dart';

class ParrotApplication implements ParrotContext {
  const ParrotApplication({
    required this.context,
  });

  /// Current compiled module context.
  final ModuleContext context;

  @override
  T get<T extends Object>(Type type) => context.get<T>(type);

  @override
  T resolve<T extends Object>(Type type) => context.resolve<T>(type);

  @override
  ModuleContext select(Type module) => context.select(module);

  /// Create a new [ParrotApplication] instance.
  static Future<ParrotApplication> create(Type module) async {
    // Create a new parrot container.
    final ParrotContainer container = ParrotContainer();

    // Compile the module.
    final ModuleContext context =
        await ModuleCompiler(container).compile(module);

    // Create and returns a new parrot application.
    return ParrotApplication(context: context);
  }
}
