import 'instance_factory.dart';

/// Instance context.
abstract class InstanceContext<T> {
  factory InstanceContext({
    required Object token,
    required InstanceFactory<T> factory,
  }) = _InstanceContextImpl<T>;

  /// Instance factory.
  InstanceFactory<T> get factory;

  /// Instance token.
  Object get token;

  /// Chack a token is equal to this token or alias.
  bool equal(Object token);

  /// Add a alias.
  void addAlias(Object alias);

  /// Cast to [InstanceContext<S>].
  InstanceContext<S> cast<S>();
}

/// Instance context implementation.
class _InstanceContextImpl<T> implements InstanceContext<T> {
  _InstanceContextImpl({
    required this.token,
    required this.factory,
  });

  @override
  final InstanceFactory<T> factory;

  @override
  final Object token;

  final Set<Object> aliases = {};

  @override
  bool equal(Object token) => this.token == token || aliases.contains(token);

  @override
  void addAlias(Object alias) {
    if (!aliases.contains(alias)) {
      aliases.add(alias);
    }
  }

  @override
  InstanceContext<S> cast<S>() {
    if (this is InstanceContext<S>) {
      return this as InstanceContext<S>;
    }

    final InstanceContext<S> context = InstanceContext<S>(
      token: token,
      factory: () async {
        final T instance = await factory();

        return instance as S;
      },
    );

    for (final Object alias in aliases) {
      context.addAlias(alias);
    }

    return context;
  }
}
