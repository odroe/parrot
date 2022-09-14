import 'injector/parrot_container.dart';
import 'parrot_context.dart';

abstract class ParrotApplication extends ParrotContext {
  ParrotApplication._(super.container);

  factory ParrotApplication(Type module) = _ParrotApplicationImpl;
}

class _ParrotApplicationImpl extends ParrotApplication {
  _ParrotApplicationImpl._({
    required this.container,
    required this.module,
  }) : super._(container);

  factory _ParrotApplicationImpl(Type module) {
    return _ParrotApplicationImpl._(
      container: ParrotContainer()..register(module),
      module: module,
    );
  }

  final ParrotContainer container;
  final Type module;

  ParrotContext get root => container.get(module) as ParrotContext;

  @override
  T get<T>(Type typeOrToken) => root.get<T>(typeOrToken);

  @override
  ParrotContext select(Type module) => root.select(module);

  @override
  T resolve<T>(Type typeOrToken) => root.resolve<T>(typeOrToken);
}
