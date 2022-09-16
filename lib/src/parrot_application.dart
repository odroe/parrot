import 'container/parrot_container.dart';
import 'container/parrot_token.dart';
import 'injector/module_compiler.dart';
import 'injector/module_context.dart';
import 'parrot_context.dart';
import 'utils/typed_symbol.dart';

class ParrotApplication implements ParrotContext {
  const ParrotApplication({
    required this.context,
  });

  /// Current compiled module context.
  final ModuleContext context;

  @override
  Future<T> get<T extends Object>(Type type) => context.get<T>(type);

  @override
  Future<T> resolve<T extends Object>(Type type) => context.resolve<T>(type);

  @override
  Future<ModuleContext> select(Type module) => context.select(module);

  /// Create a new [ParrotApplication] instance.
  static Future<ParrotApplication> create(Type module) async {
    // Create a new parrot container.
    final ParrotContainer container = ParrotContainer();

    // Compile the module.
    final ModuleContext context =
        await ModuleCompiler(container).compile(module);

    // Create and returns a new parrot application.
    final ParrotApplication app = ParrotApplication(context: context);
    container.register(SingletonToken<ParrotApplication>(
      TypedSymbol.create(ParrotApplication),
      app,
    ));

    return app;
  }
}
