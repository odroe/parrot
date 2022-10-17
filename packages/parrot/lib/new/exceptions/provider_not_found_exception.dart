part of parrot.core.exception;

/// Parrot - Provider not found exception.
class ParrotProviderNotFoundException implements ParrotException {
  /// Creates a new [ParrotProviderNotFoundException] instance.
  const ParrotProviderNotFoundException(this.provider, this.module);

  /// The provider.
  final Provider provider;

  /// The module.
  final Module module;

  @override
  String toString() => 'ParrotProviderNotFoundException: '
      'Provider "$provider" not found in module "$module".';
}

/// Parrot - Named provider not found exception.
class ParrotNamedProviderNotFoundException implements ParrotException {
  /// Creates a new [ParrotNamedProviderNotFoundException] instance.
  const ParrotNamedProviderNotFoundException(this.name, this.module);

  /// The provider name.
  final Object name;

  /// The module.
  final Module module;

  @override
  String toString() => 'ParrotNamedProviderNotFoundException: '
      'Provider with name "$name" not found in module "$module".';
}
