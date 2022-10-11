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
}
