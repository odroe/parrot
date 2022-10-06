import 'scope.dart';

/// Instance definition.
abstract class InstanceDefinition<T> {
  factory InstanceDefinition({
    required Object identifier,
    required T instance,
    required Scope scope,
  }) = _InstanceDefinitionImpl;

  /// Instance identifier.
  Object get identifier;

  /// The definition wrap instance.
  T get instance;

  /// The instance scope.
  Scope get scope;
}

class _InstanceDefinitionImpl<T> implements InstanceDefinition<T> {
  const _InstanceDefinitionImpl({
    required this.identifier,
    required this.instance,
    required this.scope,
  });

  @override
  final Object identifier;

  @override
  final T instance;

  @override
  final Scope scope;
}
