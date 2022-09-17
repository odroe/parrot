/// Parrot token.
///
/// A token is a unique identifier for a value or type provided by a [ParrotContainer].
abstract class ParrotToken<T extends Object> {
  const ParrotToken(this.identifier);

  /// The unique identifier for the token.
  final Symbol identifier;

  /// Return the [T] value of the token.
  Future<T> resolve();

  /// Return the token resolved type.
  Type get type => T;
}

/// Singleton token.
class SingletonToken<T extends Object> extends ParrotToken<T> {
  const SingletonToken(super.identifier, this.instance);

  /// The instance of the token.
  final T instance;

  @override
  Future<T> resolve() async => instance;
}

/// Transient token.
class TransientToken<T extends Object> extends ParrotToken<T> {
  const TransientToken(super.identifier, this.factory);

  /// The factory of the token.
  final Future<T> Function() factory;

  @override
  Future<T> resolve() => factory();
}
