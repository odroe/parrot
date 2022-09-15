/// Parrot Token.
///
/// The [ParrotToken] is used to save the instance in [ParrotContiner].
abstract class ParrotToken<T> implements MapEntry<Type, T> {
  const ParrotToken(this.key, this.value);

  /// The [key] of the [ParrotToken].
  @override
  final Type key;

  /// The [value] of the [ParrotToken].
  @override
  final T value;
}

/// Instance Token.
///
/// The [InstanceToken] is used to save the instance in [ParrotContiner].
class InstanceToken<T extends Object> extends ParrotToken<T> {
  const InstanceToken(super.key, super.value);
}
