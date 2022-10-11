import 'module_metadata.dart';
import 'module_ref.dart';

/// Dynamic module.
abstract class DynamicModule extends ModuleMetadata {
  const DynamicModule();

  Type get module;

  /// Override dynamic module metadata.
  Future<ModuleMetadata?> overrideMetadata(ModuleRef ref) async => null;
}
