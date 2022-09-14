import 'injector/module_context.dart';
import 'parrot_container.dart';
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
    final ParrotContainer container = ParrotContainer();
    final _ParrotApplicationImpl app = _ParrotApplicationImpl._(
      container: container,
      module: module,
    );

    // Add the application to the container.
    container[ParrotApplication] = app;

    // Compile the module.
    ModuleContext.compile(container, module);

    return app;
  }

  final ParrotContainer container;
  final Type module;

  ParrotContext get root => container[module]!;

  @override
  T get<T extends Object>(Type type) => root.get<T>(type);

  @override
  ParrotContext select(Type module) => root.select(module);

  @override
  T resolve<T extends Object>(Type type) => root.resolve<T>(type);
}
