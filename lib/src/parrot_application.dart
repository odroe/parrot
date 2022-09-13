import 'parrot_context.dart';

abstract class ParrotApplication extends ParrotContext<ParrotApplication> {
  const ParrotApplication();

  factory ParrotApplication.create(Type module) =>
      _ParrotApplicationImpl(module);
}

class _ParrotApplicationImpl extends ParrotApplication {
  _ParrotApplicationImpl(Type module);

  @override
  S get<S>() {
    throw UnimplementedError();
  }

  @override
  ParrotContext<S> select<S>() {
    throw UnimplementedError();
  }
}
