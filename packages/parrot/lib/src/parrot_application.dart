import 'container/parrot_container.dart';
import 'container/parrot_token.dart';
import 'injector/module_compiler.dart';
import 'injector/module_context.dart';
import 'injector/provider_compiler.dart';
import 'parrot_context.dart';
import 'utils/typed_symbol.dart';

class ParrotApplication implements ParrotContext {
  const ParrotApplication({
    required this.context,
    required this.container,
  });

  /// Current application container.
  final ParrotContainer container;

  /// Current compiled module context.
  final ModuleContext context;

  @override
  Future<T> get<T extends Object>(Type type) => context.get<T>(type);

  @override
  Future<T> resolve<T extends Object>(Type type) => context.resolve<T>(type);

  @override
  Future<ModuleContext> select(Type module) => context.select(module);

  /// Create a new [ParrotApplication] instance.
  static Future<ParrotApplication> create(Type rootModule) async {
    // Create a new parrot container.
    final ParrotContainer container = ParrotContainer();

    // Compile the module.
    final ModuleContext context =
        await ModuleCompiler(container).compile(rootModule);

    // Create and returns a new parrot application.
    final ParrotApplication app = ParrotApplication(
      context: context,
      container: container,
    );
    container.register(SingletonToken<ParrotApplication>(
      TypedSymbol.create(ParrotApplication),
      app,
    ));

    // Compile all providers.
    await ProviderCompiler(container).compile();

    return app;
  }
}
