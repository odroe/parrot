import '../injector/scope.dart';

class Injectable {
  const Injectable({
    this.scope = Scope.singleton,
    this.factory,
  });

  final Scope scope;
  final String? factory;
}

class Inject {
  const Inject(this.token);

  final Object token;
}
