import 'scope.dart';

/// Inject antotation.
class Inject {
  const Inject(this.identifier);

  /// Inject data identifier.
  final Object identifier;
}

/// Injectable annotation.
class Injectable implements Scopable {
  const Injectable({
    this.scope = Scope.singleton,
  });

  /// Injectable scope.
  @override
  final Scope scope;
}
