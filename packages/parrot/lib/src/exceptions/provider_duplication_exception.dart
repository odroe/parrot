part of parrot.core.exception;

/// Parrot - Provider Duplication Exception.
class ParrotProviderDuplicationException implements Exception {
  /// Creates a new [ParrotProviderDuplicationException] instance.
  const ParrotProviderDuplicationException(
      this.provider, this.module, this.duplicate);

  /// Provider.
  final Provider provider;

  /// Definition module.
  final Module module;

  /// Duplicate module.
  final Module duplicate;

  @override
  String toString() => 'ParrotProviderDuplicationException: '
      'Provider $provider is already defined in module $module, '
      'but it is also defined in module $duplicate.';
}
