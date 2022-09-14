import 'injector/module_context.dart';
import 'parrot_container.dart';
import 'parrot_context.dart';

abstract class ParrotApplication implements ParrotContext {
  factory ParrotApplication(
    Type module, {
    ParrotContainer? container,
  }) = _ParrotApplicationImpl;

  /// The application container.
  ParrotContainer get container;
}

class _ParrotApplicationImpl implements ParrotApplication {
  _ParrotApplicationImpl._({
    required this.container,
    required this.module,
  });

  factory _ParrotApplicationImpl(
    Type module, {
    ParrotContainer? container,
  }) {
    final ParrotContainer resolvedContainer = container ?? ParrotContainer();
    final _ParrotApplicationImpl app = _ParrotApplicationImpl._(
      container: resolvedContainer,
      module: module,
    );

    // Add the application to the container.
    resolvedContainer[ParrotApplication] = app;

    // Compile the module.
    ModuleContext.compile(resolvedContainer, module);

    return app;
  }

  @override
  final ParrotContainer container;

  /// The application root module.
  final Type module;

  /// Get the root module context.
  ParrotContext get root => container[module]!;

  @override
  T get<T extends Object>(Type type) => root.get<T>(type);

  @override
  ParrotContext select(Type module) => root.select(module);

  @override
  T resolve<T extends Object>(Type type) => root.resolve<T>(type);
}
