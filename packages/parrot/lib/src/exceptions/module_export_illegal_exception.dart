part of parrot.core.exception;

/// Parrot - Module export illegal exception.
///
/// Thrown when the module exports illegal object.
///
/// Legal:
///  - [Module]
///  - [Provider]
///
/// Illegal: Not same as legal.
class ParrotModuleExportIllegalException implements ParrotException {
  /// Creates a new [ParrotModuleExportIllegalException] instance.
  const ParrotModuleExportIllegalException(this.module, this.exported);

  /// Module that exports illegal object.
  final Module module;

  /// Illegal object that was exported.
  final Object exported;

  @override
  String toString() => 'ParrotModuleExportIllegalException: '
      'Module $module exports illegal object $exported.';
}
