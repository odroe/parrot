part of parrot.core.exception;

/// Parrot module not found exception.
class ParrotModuleNotFoundException implements ParrotException {
  /// Creates a new [ParrotModuleNotFoundException] instance.
  const ParrotModuleNotFoundException(this.module);

  /// Module that was not found.
  final Module module;

  @override
  String toString() => 'ParrotModuleNotFoundException: '
      'Module $module is not found.';
}
