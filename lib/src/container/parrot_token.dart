/// Parrot Token.
///
/// The [ParrotToken] is used to save the instance in [ParrotContiner].
class ParrotToken<T> implements MapEntry<Type, T> {
  const ParrotToken(this.key, this.value);

  /// The [key] of the [ParrotToken].
  @override
  final Type key;

  /// The [value] of the [ParrotToken].
  @override
  final T value;
}
