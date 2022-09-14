import 'injector/module_compiler.dart';
import 'injector/parrot_container.dart';
import 'parrot_context.dart';

abstract class ParrotApplication implements ParrotContext {
  factory ParrotApplication(Type module) = _ParrotApplicationImpl;
}

class _ParrotApplicationImpl implements ParrotApplication {
  _ParrotApplicationImpl._({
    required this.container,
    required this.module,
  });

  factory _ParrotApplicationImpl(Type module) {
    final _ParrotApplicationImpl app = _ParrotApplicationImpl._(
      container: ParrotContainer(),
      module: module,
    );

    // Register the application in container.
    app.container.register(ParrotApplication, app);

    // Create a module compiler.
    final ModuleCompiler compiler = ModuleCompiler(app.container);

    // Register module compiler in container.
    app.container.register(ModuleCompiler, compiler);

    // Register module context in container.
    app.container.register(module, compiler.compile(module));

    return app;
  }

  final ParrotContainer container;
  final Type module;

  ParrotContext get root => container.get<ParrotContext>(module);

  @override
  T get<T extends Object>(Type type) => root.get<T>(type);

  @override
  ParrotContext select(Type module) => root.select(module);

  @override
  T resolve<T extends Object>(Type type) => root.resolve<T>(type);
}
